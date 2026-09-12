import 'dart:io';
import 'package:camera/camera.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../app/di.dart';
import '../../app/theme.dart';
import '../../core/ids.dart';
import '../../core/logger.dart';
import '../../core/result.dart';
import '../../domain/models/models.dart' show RawBox;
import '../../data/db/database.dart';

const _tag = 'CaptureScreen';

class CaptureScreen extends ConsumerStatefulWidget {
  const CaptureScreen({super.key, required this.visitId});
  final String visitId;

  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends ConsumerState<CaptureScreen> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _torchOn = false;
  bool _capturing = false;
  String? _processingStage; // shown under the ring
  int? _lastLatencyMs;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        AppLogger.e(_tag, 'No cameras available');
        return;
      }
      final cam = _cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );
      final controller = CameraController(
        cam,
        ResolutionPreset.high, // ~1920px — fits the ≤1920 cap in TRD §6
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();
      if (mounted) {
        setState(() => _controller = controller);
      }
    } catch (e) {
      AppLogger.e(_tag, 'Camera init failed', e);
    }
  }

  Future<void> _toggleTorch() async {
    if (_controller == null) return;
    try {
      _torchOn = !_torchOn;
      await _controller!
          .setFlashMode(_torchOn ? FlashMode.torch : FlashMode.off);
      setState(() {});
    } catch (e) {
      AppLogger.e(_tag, 'Torch toggle failed', e);
    }
  }

  Future<void> _onShutter() async {
    if (_controller == null || _capturing) return;
    setState(() {
      _capturing = true;
      _processingStage = 'Finding packs…';
      _lastLatencyMs = null;
    });

    try {
      final start = DateTime.now().millisecondsSinceEpoch;

      // 1. Capture still image — never infer on preview stream
      final xFile = await _controller!.takePicture();
      AppLogger.i(_tag, 'Photo captured: ${xFile.path}');

      // 2. Save to app-private storage
      final appDir = await getApplicationDocumentsDirectory();
      final photoDir = Directory(p.join(appDir.path, 'photos', widget.visitId));
      await photoDir.create(recursive: true);
      final destPath = p.join(photoDir.path, '${newId()}.jpg');
      await File(xFile.path).copy(destPath);

      // 3. Decode image dimensions
      final bytes = await File(destPath).readAsBytes();
      // Quick JPEG dimension extraction from SOF0/SOF2 markers
      final dims = _readJpegDimensions(bytes);
      final w = dims.$1, h = dims.$2;

      // 4. Persist the photo row
      final db = ref.read(dbProvider);
      final photoId = newId();
      await db.into(db.visitPhotos).insert(VisitPhotosCompanion.insert(
            id: photoId,
            visitId: widget.visitId,
            filePath: destPath,
            width: w,
            height: h,
            capturedAt: start,
          ));

      // 5. Detect on the still — never on the preview stream.
      setState(() => _processingStage = 'Finding packs…');
      await _runPipeline(db, widget.visitId, photoId, destPath, w, h);
      final latency = DateTime.now().millisecondsSinceEpoch - start;
      AppLogger.i(_tag, 'Pipeline done in ${latency}ms');

      if (mounted) {
        setState(() {
          _capturing = false;
          _processingStage = null;
          _lastLatencyMs = latency;
        });
        // Navigate to review
        context.pushReplacement('/review/${widget.visitId}');
      }
    } catch (e) {
      AppLogger.e(_tag, 'Shutter error', e);
      if (mounted) setState(() { _capturing = false; _processingStage = null; });
    }
  }

  // Returns (width, height) from JPEG headers.
  (int, int) _readJpegDimensions(List<int> bytes) {
    try {
      for (var i = 0; i < bytes.length - 9; i++) {
        if (bytes[i] == 0xFF &&
            (bytes[i + 1] == 0xC0 || bytes[i + 1] == 0xC2)) {
          final h = (bytes[i + 5] << 8) | bytes[i + 6];
          final w = (bytes[i + 7] << 8) | bytes[i + 8];
          return (w, h);
        }
      }
    } catch (_) {}
    return (1920, 1080); // fallback
  }

  /// Stage A of the pipeline: detector → one `detections` row per box.
  /// With no detector loaded (T-12/T-13 pending) nothing is inserted and the
  /// rep draws boxes on /review — honest, and the loop still demos.
  Future<void> _runPipeline(AppDatabase db, String visitId, String photoId,
      String imagePath, int w, int h) async {
    final detector = ref.read(detectorProvider);
    final t0 = DateTime.now().millisecondsSinceEpoch;
    var boxes = const <RawBox>[];
    if (detector != null && detector.isLoaded) {
      switch (await detector.detect(imagePath)) {
        case Ok(:final value):
          boxes = value;
        case Err(:final failure):
          AppLogger.e(_tag, 'Detector failed — falling back to manual', failure);
      }
    }
    final latencyMs = DateTime.now().millisecondsSinceEpoch - t0;

    final now = DateTime.now().millisecondsSinceEpoch;
    await db.batch((b) {
      for (final box in boxes) {
        b.insert(db.detections, DetectionsCompanion.insert(
              id: newId(),
              visitId: visitId,
              photoId: photoId,
              x1: box.x1,
              y1: box.y1,
              x2: box.x2,
              y2: box.y2,
              detConfidence: box.score,
              createdAt: now,
            ));
      }
    });
    await (db.update(db.visitPhotos)
          ..where((t) => t.id.equals(photoId)))
        .write(VisitPhotosCompanion(
            detectLatencyMs:
                Value(detector != null && detector.isLoaded ? latencyMs : null)));
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview
          if (_controller != null && _controller!.value.isInitialized)
            CameraPreview(_controller!)
          else
            const Center(
                child: CircularProgressIndicator(color: AppColors.primary)),

          // Framing guide (faint rack outline)
          _FramingGuide(),

          // Top scrim with store context
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                ),
              ),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + Sp.sm,
                left: Sp.screen, right: Sp.screen, bottom: Sp.xl,
              ),
              child: Text(
                'Photograph the shelf rack',
                style: AppText.heading.copyWith(color: Colors.white),
              ),
            ),
          ),

          // Processing overlay
          if (_capturing) _ProcessingOverlay(stage: _processingStage ?? ''),

          // Bottom arc controls
          if (!_capturing)
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Sp.screen, vertical: Sp.lg),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Torch toggle
                      _ArcButton(
                        icon: _torchOn ? Icons.flash_on : Icons.flash_off,
                        onTap: _toggleTorch,
                        active: _torchOn,
                        size: Tap.min,
                      ),
                      // Shutter — 72 dp, primary ring
                      GestureDetector(
                        onTap: _onShutter,
                        child: Container(
                          width: Tap.shutter, height: Tap.shutter,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.primary, width: 3),
                            color: Colors.white.withOpacity(0.15),
                          ),
                          child: const Icon(Icons.camera_alt,
                              color: Colors.white, size: 32),
                        ),
                      ),
                      // Close
                      _ArcButton(
                        icon: Icons.close,
                        onTap: () => context.canPop() ? context.pop() : context.go('/beat'),
                        size: Tap.min,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ArcButton extends StatelessWidget {
  const _ArcButton(
      {required this.icon, required this.onTap, this.active = false, required this.size});
  final IconData icon;
  final VoidCallback onTap;
  final bool active;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: (active ? AppColors.primary : Colors.white).withOpacity(0.15),
        ),
        child: Icon(icon,
            color: active ? AppColors.primary : Colors.white, size: 24),
      ),
    );
  }
}

class _FramingGuide extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _FramingGuidePainter(),
    );
  }
}

class _FramingGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    const pad = 24.0;
    const corner = 20.0;
    final rect = Rect.fromLTRB(pad, size.height * 0.1,
        size.width - pad, size.height * 0.75);
    // Corner marks only — not a full rectangle
    for (final (ox, oy, sx, sy) in [
      (rect.left, rect.top, 1.0, 1.0),
      (rect.right, rect.top, -1.0, 1.0),
      (rect.left, rect.bottom, 1.0, -1.0),
      (rect.right, rect.bottom, -1.0, -1.0),
    ]) {
      canvas.drawLine(Offset(ox, oy), Offset(ox + corner * sx, oy), paint);
      canvas.drawLine(Offset(ox, oy), Offset(ox, oy + corner * sy), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _ProcessingOverlay extends StatelessWidget {
  const _ProcessingOverlay({required this.stage});
  final String stage;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.55),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 64, height: 64,
            child: CircularProgressIndicator(
              color: AppColors.primary, strokeWidth: 3),
          ),
          const SizedBox(height: Sp.lg),
          Text(stage,
              style: AppText.heading.copyWith(color: Colors.white)),
        ],
      ),
    );
  }
}
