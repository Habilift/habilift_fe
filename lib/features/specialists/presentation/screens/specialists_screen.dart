import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../home/presentation/providers/dashboard_providers.dart';
import '../providers/specialist_providers.dart';
import '../../../booking/presentation/screens/booking_screen.dart';

class SpecialistsScreen extends ConsumerWidget {
  const SpecialistsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final specialists = ref.watch(filteredSpecialistListProvider);
    final filter = ref.watch(specialistFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceGray,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.medicalGreen,
                    AppColors.medicalGreen.withValues(alpha: 0.85),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Find Specialists',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Connect with mental health professionals',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Filter Button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            IconlyBold.filter,
                            color: AppColors.medicalGreen,
                          ),
                          onPressed: () => _showFilterModal(context, ref),
                        ),
                      ),
                    ],
                  ).animate().fadeIn().slideX(begin: -0.2, end: 0),
                  const SizedBox(height: 16),
                  // Search Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      onChanged: (value) {
                        ref.read(specialistFilterProvider.notifier).state =
                            filter.copyWith(query: value);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search specialists...',
                        border: InputBorder.none,
                        icon: Icon(
                          IconlyLight.search,
                          color: AppColors.medicalGreen,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 16),
                  // Quick Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildFilterChip(
                          ref,
                          'All',
                          filter.specialty == null || filter.specialty == 'All',
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          ref,
                          'Psychologist',
                          filter.specialty == 'Psychologist',
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          ref,
                          'Therapist',
                          filter.specialty == 'Therapist',
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          ref,
                          'Psychiatrist',
                          filter.specialty == 'Psychiatrist',
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          ref,
                          'Counselor',
                          filter.specialty == 'Counselor',
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1, end: 0),
                ],
              ),
            ),

            // Specialists List
            Expanded(
              child: specialists.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            IconlyBold.search,
                            size: 64,
                            color: AppColors.textGray.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No specialists found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textGray,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      physics: const BouncingScrollPhysics(),
                      itemCount: specialists.length,
                      itemBuilder: (context, index) {
                        return _buildSpecialistCard(
                              context,
                              ref,
                              specialists[index],
                            )
                            .animate()
                            .fadeIn(delay: (100 + index * 50).ms)
                            .slideX(begin: 0.1, end: 0);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(WidgetRef ref, String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        final currentFilter = ref.read(specialistFilterProvider);
        String? newSpecialty;

        if (label == 'All') {
          newSpecialty = null;
        } else {
          // Toggle: if already selected, unselect (set to null), otherwise select
          if (currentFilter.specialty == label) {
            newSpecialty = null;
          } else {
            newSpecialty = label;
          }
        }

        ref.read(specialistFilterProvider.notifier).state = currentFilter
            .copyWith(specialty: newSpecialty);
      },
      backgroundColor: Colors.white,
      selectedColor: AppColors.medicalGreen, // High contrast when selected
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected
            ? Colors.white
            : AppColors.medicalGreen, // Green text when unselected
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.medicalGreen : Colors.white,
          width: 0,
        ),
      ),
      showCheckmark: false,
    );
  }

  void _showFilterModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterModal(ref: ref),
    );
  }

  Widget _buildSpecialistCard(
    BuildContext context,
    WidgetRef ref,
    Specialist specialist,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Row(
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
                specialist.imageUrl,
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
          const SizedBox(width: 16),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  specialist.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textBlack,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  specialist.specialty,
                  style: TextStyle(fontSize: 13, color: AppColors.textGray),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(IconlyBold.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      specialist.rating.toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      IconlyBold.timeCircle,
                      size: 14,
                      color: AppColors.medicalGreen,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${specialist.experienceYears} years',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Book Button
          Column(
            children: [
              Text(
                '${specialist.price.toInt()} XAF',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.medicalGreen,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  // Set selected specialist
                  ref.read(selectedSpecialistProvider.notifier).state =
                      specialist;
                  // Navigate to booking screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BookingScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.medicalGreen,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Book',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterModal extends ConsumerStatefulWidget {
  final WidgetRef ref;

  const _FilterModal({required this.ref});

  @override
  ConsumerState<_FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends ConsumerState<_FilterModal> {
  late RangeValues _priceRange;
  late double _minRating;
  late SortOption _sortOption;

  @override
  void initState() {
    super.initState();
    final filter = ref.read(specialistFilterProvider);
    _priceRange = filter.priceRange;
    _minRating = filter.minRating;
    _sortOption = ref.read(specialistSortProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filters & Sort',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlack,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _priceRange = const RangeValues(0, 20000);
                    _minRating = 0;
                    _sortOption = SortOption.recommended;
                  });
                },
                child: Text(
                  'Reset',
                  style: TextStyle(color: AppColors.errorRed),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sort By
                  const Text(
                    'Sort By',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildSortChip('Recommended', SortOption.recommended),
                      _buildSortChip(
                        'Price: Low to High',
                        SortOption.priceLowToHigh,
                      ),
                      _buildSortChip(
                        'Price: High to Low',
                        SortOption.priceHighToLow,
                      ),
                      _buildSortChip(
                        'Rating: High to Low',
                        SortOption.ratingHighToLow,
                      ),
                      _buildSortChip(
                        'Experience',
                        SortOption.experienceHighToLow,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Price Range
                  const Text(
                    'Price Range (XAF)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 20000,
                    divisions: 20,
                    activeColor: AppColors.medicalGreen,
                    inactiveColor: AppColors.medicalGreen.withValues(
                      alpha: 0.2,
                    ),
                    labels: RangeLabels(
                      '${_priceRange.start.toInt()}',
                      '${_priceRange.end.toInt()}',
                    ),
                    onChanged: (RangeValues values) {
                      setState(() {
                        _priceRange = values;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_priceRange.start.toInt()} XAF',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${_priceRange.end.toInt()} XAF',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Rating
                  const Text(
                    'Minimum Rating',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Slider(
                    value: _minRating,
                    min: 0,
                    max: 5,
                    divisions: 5,
                    activeColor: Colors.amber,
                    label: '$_minRating+',
                    onChanged: (double value) {
                      setState(() {
                        _minRating = value;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$_minRating+ Stars',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ref.read(specialistFilterProvider.notifier).state = ref
                    .read(specialistFilterProvider)
                    .copyWith(priceRange: _priceRange, minRating: _minRating);
                ref.read(specialistSortProvider.notifier).state = _sortOption;
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.medicalGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Apply Filters',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, SortOption option) {
    final isSelected = _sortOption == option;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() {
          _sortOption = option;
        });
      },
      selectedColor: AppColors.medicalGreen,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textBlack,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.medicalGreen : AppColors.divider,
        ),
      ),
      showCheckmark: false,
    );
  }
}
