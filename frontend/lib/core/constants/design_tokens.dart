/// Single source of truth for every magic number in the Tutorix UI.
///
/// **Rules:**
///  1. No raw numeric literal for spacing, font size, or radius in any widget.
///  2. If a value doesn't exist here, add it here first — then use it.
///  3. To change any value globally, edit the constant here.
///  4. Use *semantic* tokens (screenH, cardPad) over raw grid tokens
///     whenever intent is structural rather than mathematical.
library;

// ── Spacing ──────────────────────────────────────────────────────────────
/// 4 px base grid with practical half-steps.
/// Raw tokens for mathematical spacing (padding, margin, gap, SizedBox).
abstract final class Spacing {
  // ── Grid tokens ──
  static const double sp2 = 2;
  static const double sp4 = 4;
  static const double sp6 = 6;
  static const double sp8 = 8;
  static const double sp10 = 10;
  static const double sp12 = 12;
  static const double sp14 = 14;
  static const double sp16 = 16;
  static const double sp20 = 20;
  static const double sp24 = 24;
  static const double sp28 = 28;
  static const double sp32 = 32;
  static const double sp40 = 40;
  static const double sp48 = 48;
  static const double sp60 = 60;
  static const double sp80 = 80;

  // ── Layout dimensions (fixed UI region sizes) ──
  static const double sp100 = 100;
  static const double sp120 = 120;
  static const double sp200 = 200;

  // ── Semantic spacing ──
  /// Horizontal inset for full-width screens (left + right).
  static const double screenH = sp16;

  /// Vertical padding at top of scroll content.
  static const double screenTop = sp16;

  /// Internal padding inside cards.
  static const double cardPad = sp16;

  /// Gap between major content sections.
  static const double sectionGap = sp24;

  /// Gap between items in a list / column.
  static const double listGap = sp12;

  /// Gap between a label and its value.
  static const double labelGap = sp4;

  /// Internal padding inside chips / pills / badges.
  static const double chipH = sp10;
  static const double chipV = sp4;
}

// ── Font Size ────────────────────────────────────────────────────────────
/// 7-stop type ramp. Each size has a named role — use the role, not the
/// number, when picking a size.
///
///  | Token  | px | Role                                      |
///  |--------|----|-------------------------------------------|
///  | hero   | 32 | Splash numbers, big stat values            |
///  | title  | 20 | Screen titles, section headings            |
///  | sub    | 16 | Card titles, group labels, tab labels      |
///  | body   | 14 | Default readable paragraph text            |
///  | caption| 12 | Secondary info, metadata, timestamps       |
///  | micro  | 11 | Badges, pills, tertiary labels             |
///  | nano   | 10 | Minimal legal text, superscripts           |
abstract final class FontSize {
  static const double hero = 32;
  static const double title = 20;
  static const double sub = 16;
  static const double body = 14;
  static const double caption = 12;
  static const double micro = 11;
  static const double nano = 10;
}

// ── Border Radius ────────────────────────────────────────────────────────
/// 5 radius tokens — pick by component, not by number.
///
///  | Token | px  | Use                                 |
///  |-------|-----|-------------------------------------|
///  | sm    |  6  | Chips, pills, small badges          |
///  | md    | 12  | Inputs, buttons, inner cards        |
///  | lg    | 16  | Cards, sheets, dialogs              |
///  | xl    | 24  | Hero banners, large modals          |
///  | full  | 100 | Circles, avatar clips               |
abstract final class Radii {
  static const double sm = 6;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double full = 100;
}
