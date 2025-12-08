import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../specialists/presentation/providers/specialist_providers.dart';
import 'booked_history_screen.dart';

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  String? _selectedSessionType;

  @override
  void initState() {
    super.initState();
    // Auto-select first specialist if none selected
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(selectedSpecialistProvider) == null) {
        final specialists = ref.read(specialistListProvider);
        if (specialists.isNotEmpty) {
          ref.read(selectedSpecialistProvider.notifier).state =
              specialists.first;
        }
      }
    });
  }

  List<String> _getAvailableSlots(Specialist? specialist, DateTime date) {
    if (specialist == null) return [];

    final slots = specialist.availability[date.weekday] ?? [];

    // If date is today, filter out past times
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      final dateFormat = DateFormat('hh:mm a');
      return slots.where((slot) {
        try {
          final time = dateFormat.parse(slot);
          final slotDateTime = DateTime(
            now.year,
            now.month,
            now.day,
            time.hour,
            time.minute,
          );
          return slotDateTime.isAfter(now);
        } catch (e) {
          return true; // Keep if parsing fails
        }
      }).toList();
    }

    return slots;
  }

  String _getAvailabilityStatus(Specialist? specialist) {
    if (specialist == null) return 'Unavailable';

    final now = DateTime.now();

    // Check today
    final todaySlots = _getAvailableSlots(specialist, now);
    if (todaySlots.isNotEmpty) {
      return 'Available Today';
    }

    // Check tomorrow
    final tomorrow = now.add(const Duration(days: 1));
    final tomorrowSlots = _getAvailableSlots(specialist, tomorrow);
    if (tomorrowSlots.isNotEmpty) {
      return 'Available Tomorrow';
    }

    return 'Check Availability';
  }

  void _changeSpecialist(int direction) {
    final specialists = ref.read(specialistListProvider);
    final current = ref.read(selectedSpecialistProvider);
    if (specialists.isEmpty) return;

    int currentIndex = current != null ? specialists.indexOf(current) : 0;
    if (currentIndex == -1) currentIndex = 0;

    int newIndex = (currentIndex + direction) % specialists.length;
    if (newIndex < 0) newIndex = specialists.length - 1;

    final newSpecialist = specialists[newIndex];

    // Update State
    ref.read(selectedSpecialistProvider.notifier).state = newSpecialist;

    // Reset Date to Today (or next available if we implemented that logic)
    ref.read(bookingDateProvider.notifier).state = DateTime.now();
    // Reset Time
    ref.read(bookingTimeProvider.notifier).state = null;
  }

  @override
  Widget build(BuildContext context) {
    final selectedSpecialist = ref.watch(selectedSpecialistProvider);
    final selectedDate = ref.watch(bookingDateProvider);
    final selectedTime = ref.watch(bookingTimeProvider);

    final availableSlots = _getAvailableSlots(selectedSpecialist, selectedDate);
    final availabilityStatus = _getAvailabilityStatus(selectedSpecialist);

    return Scaffold(
      backgroundColor: AppColors.surfaceGray,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Match Header (Responsive Hero Background)
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/book_hero/hero_session_book.png'),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.medicalGreen.withValues(alpha: 0.8),
                      AppColors.medicalGreen.withValues(alpha: 0.95),
                    ],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      // Navigation Row
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                Icons.arrow_back_ios_new,
                                size: 20,
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.2,
                                ),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.all(12),
                              ),
                            ),
                            const Text(
                              'Quick Match',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 48), // Balance back button
                          ],
                        ),
                      ),

                      // Carousel Content
                      if (selectedSpecialist != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Left Arrow
                              IconButton(
                                onPressed: () => _changeSpecialist(-1),
                                icon: const Icon(IconlyLight.arrowLeft2),
                                iconSize: 32,
                                color: Colors.white,
                              ),

                              // Specialist Card
                              Expanded(
                                child: Column(
                                  children: [
                                    Hero(
                                      tag:
                                          'specialist_${selectedSpecialist.id}',
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white.withValues(
                                              alpha: 0.5,
                                            ),
                                            width: 3,
                                          ),
                                        ),
                                        child: CircleAvatar(
                                          radius: 50,
                                          backgroundImage: AssetImage(
                                            selectedSpecialist.imageUrl,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      selectedSpecialist.name,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ).animate().fadeIn().slideY(
                                      begin: 0.2,
                                      end: 0,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      selectedSpecialist.specialty,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white.withValues(
                                          alpha: 0.9,
                                        ),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            IconlyBold.timeCircle,
                                            size: 14,
                                            color: AppColors.medicalGreen,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            availabilityStatus,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.medicalGreen,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Right Arrow
                              IconButton(
                                onPressed: () => _changeSpecialist(1),
                                icon: const Icon(IconlyLight.arrowRight2),
                                iconSize: 32,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Quick Action Cards (Reschedule & Booked)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildQuickActionCard(
                      'Reschedule',
                      IconlyBold.calendar,
                      Colors.orange,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BookedHistoryScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildQuickActionCard(
                      'Booked',
                      IconlyBold.ticket,
                      AppColors.medicalBlue,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BookedHistoryScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),

            const SizedBox(height: 24),

            // Date Selection
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Date',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: 14, // Next 14 days
                      itemBuilder: (context, index) {
                        final date = DateTime.now().add(Duration(days: index));
                        final isSelected =
                            selectedDate.day == date.day &&
                            selectedDate.month == date.month &&
                            selectedDate.year == date.year;

                        return GestureDetector(
                          onTap: () {
                            ref.read(bookingDateProvider.notifier).state = date;
                            // Reset time when date changes
                            ref.read(bookingTimeProvider.notifier).state = null;
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 60,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.medicalGreen
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.medicalGreen
                                    : AppColors.divider,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.medicalGreen
                                            .withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  DateFormat('EEE').format(date),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textGray,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  date.day.toString(),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textBlack,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1, end: 0),

            const SizedBox(height: 24),

            // Time Selection
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Time',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (availableSlots.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            IconlyLight.calendar,
                            size: 48,
                            color: AppColors.textGray.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No slots available',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textBlack,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Try selecting another date or specialist',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textGray,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: availableSlots.map((time) {
                        final isSelected = selectedTime == time;
                        return ChoiceChip(
                          label: Text(time),
                          selected: isSelected,
                          onSelected: (selected) {
                            ref.read(bookingTimeProvider.notifier).state =
                                selected ? time : null;
                          },
                          selectedColor: AppColors.medicalGreen,
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textBlack,
                            fontWeight: FontWeight.w600,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.medicalGreen
                                  : AppColors.divider,
                            ),
                          ),
                          showCheckmark: false,
                        );
                      }).toList(),
                    ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1, end: 0),

            const SizedBox(height: 24),

            // Session Types
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Session Type',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSessionTypeCard(
                    icon: IconlyBold.video,
                    title: 'Video Session',
                    description: 'Face-to-face video consultation',
                    duration: '45 mins',
                    price: selectedSpecialist != null
                        ? '${selectedSpecialist.price.toInt()} XAF'
                        : '9,000 XAF',
                    color: AppColors.medicalBlue,
                    sessionType: 'video',
                  ),
                  const SizedBox(height: 16),
                  _buildSessionTypeCard(
                    icon: IconlyBold.call,
                    title: 'Voice Call',
                    description: 'Audio-only consultation',
                    duration: '45 mins',
                    price: selectedSpecialist != null
                        ? '${(selectedSpecialist.price * 0.8).toInt()} XAF'
                        : '7,200 XAF',
                    color: AppColors.medicalGreen,
                    sessionType: 'voice',
                  ),
                  const SizedBox(height: 16),
                  _buildSessionTypeCard(
                    icon: IconlyBold.chat,
                    title: 'Text Chat',
                    description: 'Messaging-based consultation',
                    duration: '60 mins',
                    price: selectedSpecialist != null
                        ? '${(selectedSpecialist.price * 0.6).toInt()} XAF'
                        : '4,800 XAF',
                    color: AppColors.warningOrange,
                    sessionType: 'text',
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.1, end: 0),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.1),
              color.withValues(alpha: 0.05),
            ],
          ),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color, // Use the theme color for text too
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionTypeCard({
    required IconData icon,
    required String title,
    required String description,
    required String duration,
    required String price,
    required Color color,
    required String sessionType,
  }) {
    final isSelected = _selectedSessionType == sessionType;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedSessionType = sessionType;
        });

        final selectedTime = ref.read(bookingTimeProvider);
        if (selectedTime == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Please select a time first'),
              backgroundColor: AppColors.errorRed,
            ),
          );
          return;
        }

        _showBookingConfirmation(context, title, price, duration, color);
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? color.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 13, color: AppColors.textGray),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(IconlyBold.timeCircle, size: 14, color: color),
                      const SizedBox(width: 4),
                      Text(
                        duration,
                        style: TextStyle(
                          fontSize: 12,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        price,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 20, color: color),
          ],
        ),
      ),
    );
  }

  void _showBookingConfirmation(
    BuildContext context,
    String sessionType,
    String price,
    String duration,
    Color color,
  ) {
    final selectedSpecialist = ref.read(selectedSpecialistProvider);
    final selectedDate = ref.read(bookingDateProvider);
    final selectedTime = ref.read(bookingTimeProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Confirm Booking',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textBlack,
              ),
            ),
            const SizedBox(height: 24),

            // Specialist Summary
            if (selectedSpecialist != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceGray,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: AssetImage(selectedSpecialist.imageUrl),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedSpecialist.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          selectedSpecialist.specialty,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textGray,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildSummaryRow(
                    'Date',
                    DateFormat('MMM d, y').format(selectedDate),
                    color,
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryRow('Time', selectedTime ?? '', color),
                  const SizedBox(height: 12),
                  _buildSummaryRow('Type', sessionType, color),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Price:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlack,
                        ),
                      ),
                      Text(
                        price,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: color),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showSuccessMessage(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Pay & Confirm',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.textGray),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textBlack,
          ),
        ),
      ],
    );
  }

  void _showSuccessMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Booking confirmed! Check "My Bookings" for details.',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.medicalGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
