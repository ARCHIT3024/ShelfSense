import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../app/theme.dart';
import '../../core/ids.dart';
import '../../core/logger.dart';
import '../../ml/common/image_crop.dart';

const _tag = 'EnrolCamera';

/// The pack guide: a centred square covering this fraction of the shorter
/// preview side. Until the detector lands (T-13) the crop *is* this guide;
/// afterwards the largest detected box inside it should win.
const _kGuideFrac = 0.72;

/// Live preview with a framing square and a shutter. Each shot is cropped to
/// the guide and handed back as a JPEG path via [onShot].
class EnrolCamera extends StatefulWidget {
  const EnrolCamera({super.key, required this.onShot, required this.hint});
  final Future<void> Function(String cropPath) onShot;
  final String hint;

  @override
  State<EnrolCamera> createState() => _EnrolCameraState();
}

class _EnrolCameraState extends State<EnrolCamera>
    with WidgetsBindingObserver {
  CameraController? _controller;
  bool _busy = false;
  bool _torch = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Release the camera when backgrounded; re-open on resume.
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
      _controller = null;
    } else if (state == AppLifecycleState.resumed && _controller == null) {
      _init();
    }
  }

  Future<void> _init() async {
    try {
      final cams = await availableCameras();
      if (cams.isEmpty) {
        setState(() => _error = 'No camera available');
        return;
      }
      final cam = cams.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cams.first,
      );
      final c = CameraController(
        cam,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await c.initialize();
      if (!mounted) {
        c.dispose();
        return;
      }
      setState(() => _controller = c);
    } catch (e) {
      AppLogger.e(_tag, 'Camera init failed', e);
      if (mounted) setState(() => _error = 'Camera unavailable');
    }
  }

  Future<void> _toggleTorch() async {
    final c = _controller;
    if (c == null) return;
    try {
      _torch = !_torch;
      await c.setFlashMode(_torch ? FlashMode.torch : FlashMode.off);
      if (mounted) setState(() {});
    } catch (e) {
      AppLogger.e(_tag, 'Torch failed', e);
    }
  }

  /// Guide square, normalised to the preview (which is shown at the sensor's
  /// own aspect ratio so the same fractions apply to the captured JPEG).
  Rect _guideRect(double aspect) {
    // aspect = width / height of the portrait preview.
    final w = aspect >= 1 ? _kGuideFrac / aspect : _kGuideFrac;
    final h = aspect >= 1 ? _kGuideFrac : _kGuideFrac * aspect;
    return Rect.fromCenter(center: const Offset(0.5, 0.5), width: w, height: h);
  }

  Future<void> _shoot() async {
    final c = _controller;
    if (c == null || _busy) return;
    setState(() => _busy = true);
    HapticFeedback.mediumImpact();
    try {
      final x = await c.takePicture();
      final tmp = await getTemporaryDirectory();
      final full = p.join(tmp.path, 'enrol_${newId()}.jpg');
      await File(x.path).copy(full);
      final g = _guideRect(1 / c.value.aspectRatio);
      final crop = await writeBoxCrop(
        srcPath: full,
        x1: g.left,
        y1: g.top,
        x2: g.right,
        y2: g.bottom,
        outName: 'enrol_${newId()}',
      );
      File(full).delete().ignore();
      await widget.onShot(crop);
    } catch (e) {
      AppLogger.e(_tag, 'Shot failed', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Shot failed. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    if (_error != null) {
      return Center(child: Text(_error!, style: AppText.body));
    }
    if (c == null || !c.value.isInitialized) {
      return Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }
    final portraitAspect = 1 / c.value.aspectRatio;

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: Colors.black),
        Center(
          child: AspectRatio(
            aspectRatio: portraitAspect,
            child: LayoutBuilder(builder: (_, box) {
              final g = _guideRect(portraitAspect);
              final rect = Rect.fromLTRB(
                g.left * box.maxWidth,
                g.top * box.maxHeight,
                g.right * box.maxWidth,
                g.bottom * box.maxHeight,
              );
              return Stack(
                fit: StackFit.expand,
                children: [
                  CameraPreview(c),
                  // Dim everything outside the guide so the crop is obvious.
                  CustomPaint(painter: _GuidePainter(rect)),
                ],
              );
            }),
          ),
        ),
        Positioned(
          top: Sp.lg,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: Sp.md, vertical: Sp.sm),
              decoration: BoxDecoration(
                color: AppColors.bg.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(Radii.pill),
              ),
              child: Text(widget.hint, style: AppText.body),
            ),
          ),
        ),
        if (_busy)
          Container(
            color: Colors.black.withValues(alpha: 0.5),
            alignment: Alignment.center,
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        Positioned(
          bottom: Sp.lg,
          left: Sp.screen,
          right: Sp.screen,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _RoundButton(
                icon: _torch ? Icons.flash_on : Icons.flash_off,
                active: _torch,
                onTap: _toggleTorch,
                semantics: 'Torch',
              ),
              GestureDetector(
                onTap: _busy ? null : _shoot,
                child: Semantics(
                  button: true,
                  label: 'Shutter',
                  child: Container(
                    width: Tap.shutter,
                    height: Tap.shutter,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 3),
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                    child: const Icon(Icons.camera_alt,
                        color: Colors.white, size: 32),
                  ),
                ),
              ),
              const SizedBox(width: Tap.min),
            ],
          ),
        ),
      ],
    );
  }
}

class _GuidePainter extends CustomPainter {
  const _GuidePainter(this.guide);
  final Rect guide;

  @override
  void paint(Canvas canvas, Size size) {
    final full = Offset.zero & size;
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(full),
        Path()..addRRect(RRect.fromRectAndRadius(guide, const Radius.circular(12))),
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.45),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(guide, const Radius.circular(12)),
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_GuidePainter old) => old.guide != guide;
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.onTap,
    required this.semantics,
    this.active = false,
  });
  final IconData icon;
  final VoidCallback onTap;
  final String semantics;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semantics,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: Tap.min,
          height: Tap.min,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: (active ? AppColors.primary : Colors.white)
                .withValues(alpha: 0.15),
          ),
          child: Icon(icon,
              color: active ? AppColors.primary : Colors.white, size: 24),
        ),
      ),
    );
  }
}
