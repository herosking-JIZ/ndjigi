// ============================================================
// SHARED/WIDGETS/LOADING_OVERLAY.DART
// Overlay de chargement réutilisable dans toute l'app
// ============================================================

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      child,
      if (isLoading)
        Container(
          color: Colors.black.withOpacity(0.35),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 20)]),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
                if (message != null) ...[
                  const SizedBox(height: 14),
                  Text(message!, style: const TextStyle(
                      fontFamily: 'Poppins', fontSize: 13, color: AppColors.textSecondary)),
                ],
              ]),
            ),
          ),
        ),
    ]);
  }
}
