import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wallet mode — custodial (server-managed) or external (Pera Wallet).
enum WalletMode { custodial, pera }

class WalletModeNotifier extends StateNotifier<WalletMode> {
  WalletModeNotifier() : super(WalletMode.custodial) {
    _load();
  }

  static const _key = 'wallet_mode';
  final _storage = const FlutterSecureStorage();

  Future<void> _load() async {
    final raw = await _storage.read(key: _key);
    if (raw == 'pera') {
      state = WalletMode.pera;
    }
  }

  Future<void> setMode(WalletMode mode) async {
    if (state == mode) return;
    state = mode;
    await _storage.write(key: _key, value: mode.name);
  }

  Future<void> toggle() async {
    final next =
        state == WalletMode.custodial ? WalletMode.pera : WalletMode.custodial;
    await setMode(next);
  }
}

final walletModeProvider =
    StateNotifierProvider<WalletModeNotifier, WalletMode>((ref) {
  return WalletModeNotifier();
});
