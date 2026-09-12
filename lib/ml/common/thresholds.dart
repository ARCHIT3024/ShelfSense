/// Single source of truth for all ML thresholds (TRD §4.1).
/// Overridable at runtime from the Diagnostics screen via AppSettings.
library;

// Detector
const double kDetConfThreshold = 0.35;
const double kDetNmsIou = 0.50;
const int kDetMaxBoxes = 100;

// Matcher
const double kMatchHigh = 0.72; // accept
const double kMatchLow = 0.55; // below this = unmatched

// Enrolment
const int kMinEnrolShots = 3;
const int kTargetEnrolShots = 8;

// Gap detection (fraction of image area)
const double kGapMinArea = 0.004;

/// Context labels for enrolment shots.
const List<String> kEnrolContexts = ['bright', 'dim', 'angled', 'occluded'];
