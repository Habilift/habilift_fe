import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- Models ---

class Appointment {
  final String id;
  final String specialistId;
  final DateTime date;
  final String time;
  final String type; // 'video', 'voice', 'text'
  final String status; // 'upcoming', 'completed', 'cancelled'
  final double price;
  final String? notes;

  Appointment({
    required this.id,
    required this.specialistId,
    required this.date,
    required this.time,
    required this.type,
    required this.status,
    required this.price,
    this.notes,
  });
}

class Specialist {
  final String id;
  final String name;
  final String specialty;
  final double rating;
  final int experienceYears;
  final double price;
  final String imageUrl;
  final String gender; // 'Male', 'Female'
  final List<String> languages;
  final Map<int, List<String>> availability; // Key: Weekday (1=Mon, 7=Sun)

  Specialist({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.experienceYears,
    required this.price,
    required this.imageUrl,
    required this.gender,
    required this.languages,
    required this.availability,
  });
}

class SpecialistFilter {
  final String query;
  final String? specialty;
  final RangeValues priceRange;
  final double minRating;
  final String? gender;
  final String? language;

  SpecialistFilter({
    this.query = '',
    this.specialty,
    this.priceRange = const RangeValues(0, 20000),
    this.minRating = 0,
    this.gender,
    this.language,
  });

  SpecialistFilter copyWith({
    String? query,
    String? specialty,
    RangeValues? priceRange,
    double? minRating,
    String? gender,
    String? language,
  }) {
    return SpecialistFilter(
      query: query ?? this.query,
      specialty: specialty ?? this.specialty,
      priceRange: priceRange ?? this.priceRange,
      minRating: minRating ?? this.minRating,
      gender: gender ?? this.gender,
      language: language ?? this.language,
    );
  }
}

enum SortOption {
  recommended,
  priceLowToHigh,
  priceHighToLow,
  ratingHighToLow,
  experienceHighToLow,
}

// --- Providers ---

// Mock Data Provider
final specialistListProvider = Provider<List<Specialist>>((ref) {
  // Common Schedules
  final fullDay = [
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
  ];
  final morningOnly = ['08:00 AM', '09:00 AM', '10:00 AM', '11:00 AM'];
  final afternoonOnly = [
    '01:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '05:00 PM',
  ];

  return [
    Specialist(
      id: '1',
      name: 'Dr. Sarah Chen',
      specialty: 'Clinical Psychologist',
      rating: 4.9,
      experienceYears: 12,
      price: 9000,
      imageUrl: 'assets/profile/profile1.webp',
      gender: 'Female',
      languages: ['English', 'Chinese'],
      availability: {
        1: fullDay, // Mon
        2: fullDay, // Tue
        3: morningOnly, // Wed
        4: fullDay, // Thu
        5: afternoonOnly, // Fri
      },
    ),
    Specialist(
      id: '2',
      name: 'Dr. Michael Obi',
      specialty: 'Therapist',
      rating: 4.8,
      experienceYears: 8,
      price: 7200,
      imageUrl: 'assets/profile/profile2.webp',
      gender: 'Male',
      languages: ['English', 'Igbo'],
      availability: {
        1: afternoonOnly,
        3: afternoonOnly,
        5: fullDay,
        6: morningOnly, // Sat
      },
    ),
    Specialist(
      id: '3',
      name: 'Dr. Amina Yusuf',
      specialty: 'Counselor',
      rating: 4.7,
      experienceYears: 10,
      price: 6000,
      imageUrl: 'assets/profile/profile3.webp',
      gender: 'Female',
      languages: ['English', 'Hausa'],
      availability: {2: fullDay, 4: fullDay, 6: fullDay},
    ),
    Specialist(
      id: '4',
      name: 'Dr. John Adeyemi',
      specialty: 'Psychiatrist',
      rating: 4.9,
      experienceYears: 15,
      price: 12000,
      imageUrl: 'assets/profile/profile4.webp',
      gender: 'Male',
      languages: ['English', 'Yoruba'],
      availability: {
        1: morningOnly,
        2: morningOnly,
        3: morningOnly,
        4: morningOnly,
        5: morningOnly,
      },
    ),
    Specialist(
      id: '5',
      name: 'Dr. Grace Eze',
      specialty: 'Family Therapist',
      rating: 4.8,
      experienceYears: 9,
      price: 7800,
      imageUrl: 'assets/profile/profile5.webp',
      gender: 'Female',
      languages: ['English'],
      availability: {1: fullDay, 3: fullDay, 5: fullDay},
    ),
    Specialist(
      id: '6',
      name: 'Dr. Ibrahim Musa',
      specialty: 'Child Psychologist',
      rating: 4.9,
      experienceYears: 11,
      price: 8400,
      imageUrl: 'assets/profile/profile6.webp',
      gender: 'Male',
      languages: ['English', 'Hausa'],
      availability: {2: afternoonOnly, 4: afternoonOnly, 6: morningOnly},
    ),
    Specialist(
      id: '7',
      name: 'Dr. Chioma Nwosu',
      specialty: 'Behavioral Therapist',
      rating: 4.7,
      experienceYears: 7,
      price: 6600,
      imageUrl: 'assets/profile/profile7.webp',
      gender: 'Female',
      languages: ['English', 'Igbo'],
      availability: {
        1: fullDay,
        2: fullDay,
        3: fullDay,
        4: fullDay,
        5: fullDay,
      },
    ),
    Specialist(
      id: '8',
      name: 'Dr. Ahmed Bello',
      specialty: 'Addiction Counselor',
      rating: 4.8,
      experienceYears: 13,
      price: 9600,
      imageUrl: 'assets/profile/profile8.webp',
      gender: 'Male',
      languages: ['English'],
      availability: {1: afternoonOnly, 2: afternoonOnly, 3: afternoonOnly},
    ),
  ];
});

// State Providers
final specialistFilterProvider = StateProvider<SpecialistFilter>((ref) {
  return SpecialistFilter();
});

final specialistSortProvider = StateProvider<SortOption>((ref) {
  return SortOption.recommended;
});

// Filtered and Sorted List Provider
final filteredSpecialistListProvider = Provider<List<Specialist>>((ref) {
  final allSpecialists = ref.watch(specialistListProvider);
  final filter = ref.watch(specialistFilterProvider);
  final sortOption = ref.watch(specialistSortProvider);

  // 1. Filter
  var filtered = allSpecialists.where((specialist) {
    // Search Query
    if (filter.query.isNotEmpty) {
      final queryLower = filter.query.toLowerCase();
      final matchesName = specialist.name.toLowerCase().contains(queryLower);
      final matchesSpecialty = specialist.specialty.toLowerCase().contains(
        queryLower,
      );
      if (!matchesName && !matchesSpecialty) return false;
    }

    // Specialty
    if (filter.specialty != null && filter.specialty != 'All') {
      if (!specialist.specialty.toLowerCase().contains(
        filter.specialty!.toLowerCase(),
      )) {
        return false;
      }
    }

    // Price Range
    if (specialist.price < filter.priceRange.start ||
        specialist.price > filter.priceRange.end) {
      return false;
    }

    // Rating
    if (specialist.rating < filter.minRating) return false;

    // Gender
    if (filter.gender != null && filter.gender != 'Any') {
      if (specialist.gender != filter.gender) return false;
    }

    // Language
    if (filter.language != null && filter.language != 'Any') {
      if (!specialist.languages.contains(filter.language)) return false;
    }

    return true;
  }).toList();

  // 2. Sort
  switch (sortOption) {
    case SortOption.priceLowToHigh:
      filtered.sort((a, b) => a.price.compareTo(b.price));
      break;
    case SortOption.priceHighToLow:
      filtered.sort((a, b) => b.price.compareTo(a.price));
      break;
    case SortOption.ratingHighToLow:
      filtered.sort((a, b) => b.rating.compareTo(a.rating));
      break;
    case SortOption.experienceHighToLow:
      filtered.sort((a, b) => b.experienceYears.compareTo(a.experienceYears));
      break;
    case SortOption.recommended:
      // Default sort (e.g., by ID or original order)
      break;
  }

  return filtered;
});

// Booking State Providers
final selectedSpecialistProvider = StateProvider<Specialist?>((ref) => null);
final bookingDateProvider = StateProvider<DateTime>((ref) => DateTime.now());
final bookingTimeProvider = StateProvider<String?>((ref) => null);

// Appointments Provider
final appointmentsProvider = StateProvider<List<Appointment>>((ref) {
  // Mock Data
  return [
    Appointment(
      id: '101',
      specialistId: '1',
      date: DateTime.now().add(const Duration(days: 2)),
      time: '10:00 AM',
      type: 'video',
      status: 'upcoming',
      price: 9000,
    ),
    Appointment(
      id: '102',
      specialistId: '3',
      date: DateTime.now().subtract(const Duration(days: 5)),
      time: '02:00 PM',
      type: 'voice',
      status: 'completed',
      price: 6000,
      notes:
          'Patient showed signs of improvement. Recommended daily meditation.',
    ),
  ];
});
