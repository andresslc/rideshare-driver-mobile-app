// import 'package:driver_app/features/user_profile/domain/entites/user_entity.dart';
// import 'package:driver_app/features/user_profile/presentation/widgets/section_status_badge.dart';
import 'package:driver_app/shared/widgets/app_gradient_box.dart';
import 'package:flutter/material.dart';

class ProfileSectionTile extends StatelessWidget {
  final String title;
  // final SectionReviewEntity review;
  // final List<String> fileUrls;
  final VoidCallback onTap;

  const ProfileSectionTile({
    super.key,
    required this.title,
    // required this.review,
    // required this.fileUrls,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // final hasReason = review.rejectReason?.trim().isNotEmpty == true;
    // final hasFiles = fileUrls.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AppGradientBox(
        cornerRadius: 18,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // SectionStatusBadge(status: review.status),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right),
              ],
            ),
            // if (hasReason) ...[
            //   const SizedBox(height: 10),
            //   Text(
            //     review.rejectReason!,
            //     style: const TextStyle(
            //       color: Color(0xFFFF6B6B),
            //       fontSize: 12,
            //       fontWeight: FontWeight.w500,
            //     ),
            //   ),
            // ],
            // if (hasFiles) ...[
            //   const SizedBox(height: 10),
            //   SizedBox(
            //     height: 44,
            //     child: ListView.separated(
            //       scrollDirection: Axis.horizontal,
            //       itemBuilder: (context, index) {
            //         final imageUrl = fileUrls[index];
            //         return ClipRRect(
            //           borderRadius: BorderRadius.circular(8),
            //           child: Container(
            //             width: 44,
            //             height: 44,
            //             color: Colors.white12,
            //             child: Image.network(
            //               imageUrl,
            //               fit: BoxFit.cover,
            //               errorBuilder: (_, _, _) => const Icon(Icons.image),
            //             ),
            //           ),
            //         );
            //       },
            //       separatorBuilder: (context, _) => const SizedBox(width: 8),
            //       itemCount: fileUrls.length,
            //     ),
            //   ),
            // ],
          ],
        ),
      ),
    );
  }
}
