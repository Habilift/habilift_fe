import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import '../../../../app/theme/app_colors.dart';

class SpecialistCarousel extends StatelessWidget {
  const SpecialistCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Top Specialists',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlack,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'See All',
                  style: TextStyle(
                    color: AppColors.medicalGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.separated(
            padding: EdgeInsets.zero,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: 5,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return _buildSpecialistCard(
                context,
                index + 2, // Use profile2 through profile6
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialistCard(BuildContext context, int profileIndex) {
    final specialists = [
      {'name': 'Dr. Sarah Chen', 'specialty': 'Psychologist', 'rating': '4.9'},
      {'name': 'Dr. Michael Obi', 'specialty': 'Therapist', 'rating': '4.8'},
      {'name': 'Dr. Amina Yusuf', 'specialty': 'Counselor', 'rating': '4.7'},
      {'name': 'Dr. John Doe', 'specialty': 'Psychiatrist', 'rating': '4.9'},
      {'name': 'Dr. Grace Eze', 'specialty': 'Psychologist', 'rating': '4.8'},
    ];

    final specialist = specialists[profileIndex - 2];

    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Profile Picture
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.medicalGreen.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/profile/profile$profileIndex.webp',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.surfaceGray,
                    child: Icon(
                      Icons.person,
                      color: AppColors.medicalGreen,
                      size: 35,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Name
          Text(
            specialist['name']!,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.textBlack,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),

          // Specialty
          Text(
            specialist['specialty']!,
            style: TextStyle(fontSize: 12, color: AppColors.textGray),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Rating
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.medicalGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(IconlyBold.star, size: 14, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  specialist['rating']!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBlack,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
