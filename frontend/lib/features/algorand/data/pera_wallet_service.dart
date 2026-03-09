import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';

/// Lightweight Pera Wallet integration using deep links.
///
/// Flow:
/// 1. User enters their Pera Wallet Algorand address (or scans QR)
/// 2. Address is saved locally
/// 3. For transactions, we open Pera Wallet via `algorand://` deep link
/// 4. Backend creates unsigned txns, Pera signs them
///
/// WalletConnect Project ID: 5ef2456bedfbe47c8c6a3e7f9b9173d5
class PeraWalletService {
  PeraWalletService._();
  static final instance = PeraWalletService._();

  static const _addressKey = 'pera_wallet_address';
  static const _projectId = '5ef2456bedfbe47c8c6a3e7f9b9173d5';
  final _storage = const FlutterSecureStorage();

  /// Get the saved Pera Wallet address.
  Future<String?> getSavedAddress() async {
    return _storage.read(key: _addressKey);
  }

  /// Save a Pera Wallet address locally.
  Future<void> saveAddress(String address) async {
    await _storage.write(key: _addressKey, value: address);
  }

  /// Clear the saved Pera Wallet address (disconnect).
  Future<void> disconnect() async {
    await _storage.delete(key: _addressKey);
  }

  /// Check if an address looks like a valid Algorand address (58 chars, alphanumeric).
  bool isValidAlgorandAddress(String address) {
    if (address.length != 58) return false;
    return RegExp(r'^[A-Z2-7]+$').hasMatch(address);
  }

  /// Open Pera Wallet app on the device.
  /// Returns true if the app was opened, false if not installed.
  Future<bool> openPeraWallet() async {
    // Try Pera Wallet deep link
    final peraUri = Uri.parse('algorand://');
    if (await canLaunchUrl(peraUri)) {
      await launchUrl(peraUri, mode: LaunchMode.externalApplication);
      return true;
    }

    // Fallback: open Pera Wallet on Play Store / App Store
    final storeUri = Uri.parse(
      'https://play.google.com/store/apps/details?id=com.algorand.android',
    );
    await launchUrl(storeUri, mode: LaunchMode.externalApplication);
    return false;
  }

  /// Open a transaction on Algorand explorer (for verification).
  Future<void> openTransaction(String txId, {bool testnet = true}) async {
    final network = testnet ? 'testnet' : 'mainnet';
    final uri = Uri.parse('https://$network.explorer.perawallet.app/tx/$txId');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  /// Open an address on Algorand explorer.
  Future<void> openAddress(String address, {bool testnet = true}) async {
    final network = testnet ? 'testnet' : 'mainnet';
    final uri = Uri.parse(
      'https://$network.explorer.perawallet.app/address/$address',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  /// WalletConnect project ID (for future full WC v2 integration).
  String get projectId => _projectId;
}
