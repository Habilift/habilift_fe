import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../specialists/presentation/providers/specialist_providers.dart';

class RescheduleScreen extends ConsumerStatefulWidget {
  final Appointment appointment;

  const RescheduleScreen({super.key, required this.appointment});

  @override
  ConsumerState<RescheduleScreen> createState() => _RescheduleScreenState();
}

class _RescheduleScreenState extends ConsumerState<RescheduleScreen> {
  late DateTime _selectedDate;
  String? _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.appointment.date;
    // Don't pre-select time to force user to pick a new one, or pre-select current?
    // Let's pre-select current for context, but user must change it ideally.
    _selectedTime = widget.appointment.time;
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
          return true;
        }
      }).toList();
    }

    return slots;
  }

  @override
  Widget build(BuildContext context) {
    final specialists = ref.watch(specialistListProvider);
    final specialist = specialists.firstWhere(
      (s) => s.id == widget.appointment.specialistId,
      orElse: () => specialists.first,
    );

    final availableSlots = _getAvailableSlots(specialist, _selectedDate);

    return Scaffold(
      backgroundColor: AppColors.surfaceGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: AppColors.textBlack,
        ),
        title: const Text(
          'Reschedule Session',
          style: TextStyle(
            color: AppColors.textBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Appointment Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.medicalGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.medicalGreen.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    IconlyBold.infoSquare,
                    color: AppColors.medicalGreen,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current Booking',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.medicalGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${DateFormat('MMM d, y').format(widget.appointment.date)} at ${widget.appointment.time}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textBlack,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Specialist Info
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage(specialist.imageUrl),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      specialist.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      specialist.specialty,
                      style: TextStyle(color: AppColors.textGray),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Date Selection
            const Text(
              'Select New Date',
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
                itemCount: 14,
                itemBuilder: (context, index) {
                  final date = DateTime.now().add(Duration(days: index));
                  final isSelected =
                      _selectedDate.day == date.day &&
                      _selectedDate.month == date.month &&
                      _selectedDate.year == date.year;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDate = date;
                        _selectedTime = null; // Reset time
                      });
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
                                  color: AppColors.medicalGreen.withValues(
                                    alpha: 0.3,
                                  ),
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
            const SizedBox(height: 24),

            // Time Selection
            const Text(
              'Select New Time',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textBlack,
              ),
            ),
            const SizedBox(height: 16),
            if (availableSlots.isEmpty)
              const Text('No slots available for this date.')
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: availableSlots.map((time) {
                  final isSelected = _selectedTime == time;
                  return ChoiceChip(
                    label: Text(time),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedTime = selected ? time : null;
                      });
                    },
                    selectedColor: AppColors.medicalGreen,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textBlack,
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
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: _selectedTime == null
                ? null
                : () {
                    // TODO: Implement actual reschedule logic (update provider)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Appointment rescheduled successfully!'),
                        backgroundColor: AppColors.medicalGreen,
                      ),
                    );
                    Navigator.pop(context); // Go back to history
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.medicalGreen,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              disabledBackgroundColor: AppColors.textGray.withValues(
                alpha: 0.3,
              ),
            ),
            child: const Text(
              'Confirm Reschedule',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
