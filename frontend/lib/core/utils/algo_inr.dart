import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';

// ── ALGO → INR rate provider ────────────────────────────────
//
// Fetches the live rate from CoinGecko (free, no key).
// Falls back to a hardcoded approximate rate on failure.

const double _fallbackRate = 15.0; // ₹15 per ALGO (approx.)

final _dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 5)));

final algoInrRateProvider = FutureProvider<double>((ref) async {
  try {
    final res = await _dio.get(
      'https://api.coingecko.com/api/v3/simple/price',
      queryParameters: {'ids': 'algorand', 'vs_currencies': 'inr'},
    );
    final data = res.data as Map<String, dynamic>;
    final algo = data['algorand'] as Map<String, dynamic>;
    return (algo['inr'] as num).toDouble();
  } catch (_) {
    return _fallbackRate;
  }
});

// ── Helper functions ────────────────────────────────────────

/// Format ALGO amount for display: "10 ALGO" or "2.5 ALGO"
String formatAlgo(double algo) {
  final display = algo == algo.roundToDouble()
      ? algo.toStringAsFixed(0)
      : algo.toStringAsFixed(1);
  return '$display ALGO';
}

/// Convert ALGO to INR string: "₹150.00"
String algoToInrString(double algo, double rate) {
  final inr = algo * rate;
  if (inr >= 1000) {
    return '₹${(inr / 1000).toStringAsFixed(1)}K';
  }
  return '₹${inr.toStringAsFixed(inr < 10 ? 2 : 0)}';
}

/// Combined display: "10 ALGO (~₹150)"
String formatAlgoWithInr(double algo, double rate) {
  return '${formatAlgo(algo)} (~${algoToInrString(algo, rate)})';
}

// ── Reusable widget ─────────────────────────────────────────

/// Inline widget that shows "X ALGO" with a subtle "~₹Y" underneath or beside.
class AlgoAmount extends ConsumerWidget {
  final double amount;
  final double fontSize;
  final Color? color;
  final bool showInrBelow;

  const AlgoAmount({
    super.key,
    required this.amount,
    this.fontSize = 14,
    this.color,
    this.showInrBelow = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rateAsync = ref.watch(algoInrRateProvider);
    final c = color ?? AppColors.neonGreen;
    final display = amount == amount.roundToDouble()
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(1);

    return rateAsync.when(
      data: (rate) {
        final inr = algoToInrString(amount, rate);
        if (showInrBelow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$display ALGO',
                style: TextStyle(
                  color: c,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                ),
              ),
              Text(
                '~$inr',
                style: TextStyle(
                  color: AppColors.textHint,
                  fontSize: fontSize * 0.75,
                ),
              ),
            ],
          );
        }
        return Text(
          '$display ALGO (~$inr)',
          style: TextStyle(
            color: c,
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            fontFamily: 'monospace',
          ),
        );
      },
      loading: () => Text(
        '$display ALGO',
        style: TextStyle(
          color: c,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          fontFamily: 'monospace',
        ),
      ),
      error: (_, __) => Text(
        '$display ALGO',
        style: TextStyle(
          color: c,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}

/// Compact chip that shows ALGO + INR — used in bounty cards
class AlgoRewardChip extends ConsumerWidget {
  final double amount;

  const AlgoRewardChip({super.key, required this.amount});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rateAsync = ref.watch(algoInrRateProvider);
    final display = amount == amount.roundToDouble()
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(1);

    final rate = rateAsync.valueOrNull ?? _fallbackRate;
    final inr = algoToInrString(amount, rate);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.neonGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$display A · $inr',
        style: const TextStyle(
          color: AppColors.neonGreen,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}
