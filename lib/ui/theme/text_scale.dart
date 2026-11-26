import 'package:flutter/widgets.dart';

/// Largest system text size the layouts are checked for.
const double maxAppTextScale = 1.3;

/// The system text size, never smaller than the design and at most
/// [maxAppTextScale] (BUG-033).
TextScaler appTextScaler(TextScaler system) =>
    system.clamp(minScaleFactor: 1.0, maxScaleFactor: maxAppTextScale);
