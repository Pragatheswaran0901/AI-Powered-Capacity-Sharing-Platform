import 'package:flutter/material.dart';

class AppColors {
  // Mach-Hunt Controlled Industrial Palette
  static const Color primaryNavy = Color(
    0xFF102A43,
  ); // #102A43 - Major headings, primary text, form values
  static const Color darkNavy = Color(
    0xFF0B1B33,
  ); // #0B1B33 - Sidebar, deepest surfaces
  static const Color secondarySlate = Color(
    0xFF52657A,
  ); // #52657A - Subtitles, labels, metadata
  static const Color mutedSlate = Color(
    0xFF71839A,
  ); // #71839A - Hints, formula, muted info
  static const Color lightBorder = Color(
    0xFFD9E2EC,
  ); // #D9E2EC - Card & input borders
  static const Color softSurface = Color(
    0xFFF8FAFC,
  ); // #F8FAFC - Soft background surface
  static const Color machOrange = Color(
    0xFFF97316,
  ); // #F97316 - Manufacturing / action accent
  static const Color machBlue = Color(
    0xFF2563EB,
  ); // #2563EB - Discovery, matching, primary actions
  static const Color successGreen = Color(
    0xFF16A34A,
  ); // #16A34A - Availability, verified, success
  static const Color warmAmber = Color(
    0xFFF59E0B,
  ); // #F59E0B - Pending, rating stars

  // Brand Industrial Palette
  static const Color primary = primaryNavy; // #102A43
  static const Color primaryLight = Color(0xFF1E3A8A);
  static const Color secondary = machBlue; // #2563EB
  static const Color accent = machOrange; // #F97316

  // Neutrals & Surfaces
  static const Color background = softSurface; // #F8FAFC
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color lightSurface = softSurface; // #F8FAFC
  static const Color border = lightBorder; // #D9E2EC
  static const Color borderSubtle = Color(0xFFF1F5F9);

  // Typography Colors
  static const Color textPrimary = primaryNavy; // #102A43
  static const Color textSecondary = secondarySlate; // #52657A
  static const Color textMuted = mutedSlate; // #71839A

  // Functional Status Colors
  static const Color success = successGreen; // #16A34A
  static const Color successBg = Color(0xFFECFDF5);
  static const Color warning = warmAmber; // #F59E0B
  static const Color warningBg = Color(0xFFFFFBEB);
  static const Color error = Color(0xFFDC2626);
  static const Color errorBg = Color(0xFFFEF2F2);
  static const Color info = machBlue; // #2563EB
  static const Color infoBg = Color(0xFFEFF6FF);

  // Match Scoring Palette
  static const Color matchHigh = successGreen; // #16A34A
  static const Color matchMedium = warmAmber; // #F59E0B
  static const Color matchLow = mutedSlate; // #71839A

  // Extended UI Tokens
  static const Color navyDark = darkNavy; // #0B1B33
  static const Color navyIndustrial = primaryNavy; // #102A43
  static const Color navySurface = Color(0xFF162A45);
  static const Color navyCard = Color(0xFF112240);
  static const Color slateLight = Color(0xFFF1F5F9);
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = lightBorder; // #D9E2EC
  static const Color slate300 = Color(0xFFC7D5E5);
  static const Color slate400 = mutedSlate; // #71839A
  static const Color slate500 = Color(0xFF627D98);
  static const Color slate600 = secondarySlate; // #52657A
  static const Color slate700 = Color(0xFF334E68);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = darkNavy; // #0B1B33
  static const Color steelBlue = machBlue; // #2563EB
  static const Color steelBlueLight = Color(0xFF60A5FA);
  static const Color amberWarm = warmAmber; // #F59E0B
  static const Color orangeAccent = machOrange; // #F97316
  static const Color orangeDark = Color(0xFFEA580C);
  static const Color orangeBg = Color(0xFFFFF7ED);
  static const Color emerald = successGreen; // #16A34A
  static const Color emeraldLight = Color(0xFF22C55E);
  static const Color emeraldBg = Color(0xFFECFDF5);
  static const Color emeraldVerified = successGreen; // #16A34A
  static const Color emeraldDark = Color(0xFF15803D);
  static const Color errorRed = Color(0xFFDC2626);
}
