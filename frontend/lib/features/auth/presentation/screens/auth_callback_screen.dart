import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../providers/auth_provider.dart';

/// Handles OAuth callback redirect with tokens in query params.
class AuthCallbackScreen extends ConsumerStatefulWidget {
  final String? accessToken;
  final String? refreshToken;

  const AuthCallbackScreen({
    super.key,
    this.accessToken,
    this.refreshToken,
  });

  @override
  ConsumerState<AuthCallbackScreen> createState() =>
      _AuthCallbackScreenState();
}

class _AuthCallbackScreenState extends ConsumerState<AuthCallbackScreen> {
  @override
  void initState() {
    super.initState();
    _handleCallback();
  }

  Future<void> _handleCallback() async {
    if (widget.accessToken != null && widget.refreshToken != null) {
      await ref.read(authProvider.notifier).loginWithOAuthTokens(
            widget.accessToken!,
            widget.refreshToken!,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.status == AuthStatus.authenticated) {
        context.go(AppRoutes.home);
      }
      if (next.error != null) {
        context.go(AppRoutes.login);
      }
    });

    return const Scaffold(
      body: LoadingOverlay(),
    );
  }
}
