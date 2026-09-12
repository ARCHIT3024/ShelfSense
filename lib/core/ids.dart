import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Generate a new UUID v4 string for use as a primary key.
String newId() => _uuid.v4();
