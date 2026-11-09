import 'package:driver_app/features/user_profile/domain/entites/user_entity.dart';
import 'package:flutter/material.dart';

class SectionStatusBadge extends StatelessWidget {
  final ProfileSectionStatus status;

  const SectionStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

Color _statusColor(ProfileSectionStatus status) {
  switch (status) {
    case ProfileSectionStatus.approved:
      return const Color(0xFF61CB08);
    case ProfileSectionStatus.pending:
      return const Color(0xFFFFB020);
    case ProfileSectionStatus.rejected:
      return const Color(0xFFFF4D4F);
    case ProfileSectionStatus.unknown:
      return const Color(0xFF9EA4AA);
  }
}
