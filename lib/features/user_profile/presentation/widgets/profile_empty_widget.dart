import 'package:driver_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class ProfileEmptyState extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onRetry;

  const ProfileEmptyState({
    super.key,
    required this.isLoading,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(AppLocalizations.of(context)!.profileUnableToLoad),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: Text(AppLocalizations.of(context)!.profileRetry)),
        ],
      ),
    );
  }
}
