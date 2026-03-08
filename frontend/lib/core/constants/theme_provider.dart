import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Manages the current [ThemeMode], font family, and text scale,
/// persisting all preferences via secure storage.
class ThemeProvider extends ChangeNotifier {
  ThemeProvider() {
    _load();
  }

  static const _keyMode = 'theme_mode';
  static const _keyFont = 'font_family';
  static const _keyScale = 'text_scale';
  final _storage = const FlutterSecureStorage();

  // ── Theme mode ─────────────────────────────────────────────────────────

  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  // ── Font family ────────────────────────────────────────────────────────

  /// `null` → use the hardcoded app default ('SF Pro'). Otherwise a Google
  /// Fonts family name such as 'Inter', 'Poppins', etc.
  String? _fontFamily;
  String? get fontFamily => _fontFamily;

  /// Available font options shown in the settings screen.
  /// Key = display label, Value = Google Fonts family name (null = default).
  static const fontOptions = <({String label, String? family, IconData icon})>[
    (label: 'Default', family: null, icon: Icons.smartphone_rounded),
    (label: 'Inter', family: 'Inter', icon: Icons.text_fields_rounded),
    (label: 'Poppins', family: 'Poppins', icon: Icons.font_download_rounded),
    (label: 'Nunito', family: 'Nunito', icon: Icons.text_format_rounded),
    (label: 'Lora', family: 'Lora', icon: Icons.menu_book_rounded),
    (
      label: 'JetBrains Mono',
      family: 'JetBrains Mono',
      icon: Icons.code_rounded,
    ),
  ];

  // ── Text scale ─────────────────────────────────────────────────────────

  double _textScale = 1.0;
  double get textScale => _textScale;

  /// Preset scale levels.
  static const scaleOptions = <({String label, double scale, IconData icon})>[
    (label: 'Small', scale: 0.85, icon: Icons.text_decrease_rounded),
    (label: 'Normal', scale: 1.0, icon: Icons.text_fields_rounded),
    (label: 'Large', scale: 1.15, icon: Icons.text_increase_rounded),
    (label: 'Extra Large', scale: 1.3, icon: Icons.format_size_rounded),
  ];

  // ── Load ───────────────────────────────────────────────────────────────

  Future<void> _load() async {
    final rawMode = await _storage.read(key: _keyMode);
    if (rawMode != null) {
      _mode = ThemeMode.values.firstWhere(
        (e) => e.name == rawMode,
        orElse: () => ThemeMode.system,
      );
    }
    _fontFamily = await _storage.read(key: _keyFont);
    final rawScale = await _storage.read(key: _keyScale);
    if (rawScale != null) {
      _textScale = double.tryParse(rawScale) ?? 1.0;
    }
    notifyListeners();
  }

  // ── Setters ────────────────────────────────────────────────────────────

  Future<void> setMode(ThemeMode m) async {
    if (_mode == m) return;
    _mode = m;
    notifyListeners();
    await _storage.write(key: _keyMode, value: m.name);
  }

  Future<void> setFontFamily(String? family) async {
    if (_fontFamily == family) return;
    _fontFamily = family;
    notifyListeners();
    if (family == null) {
      await _storage.delete(key: _keyFont);
    } else {
      await _storage.write(key: _keyFont, value: family);
    }
  }

  Future<void> setTextScale(double scale) async {
    if (_textScale == scale) return;
    _textScale = scale;
    notifyListeners();
    await _storage.write(key: _keyScale, value: scale.toString());
  }

  /// Convenience cycle: system → light → dark → system
  Future<void> toggle() async {
    final next = switch (_mode) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
    await setMode(next);
  }
}
