import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds all onboarding form data across steps.
class OnboardingData {
  final String fullName;
  final String phone;
  final String reason;
  final List<String> skills;
  final String location;
  final double? latitude;
  final double? longitude;

  const OnboardingData({
    this.fullName = '',
    this.phone = '',
    this.reason = '',
    this.skills = const [],
    this.location = '',
    this.latitude,
    this.longitude,
  });

  OnboardingData copyWith({
    String? fullName,
    String? phone,
    String? reason,
    List<String>? skills,
    String? location,
    double? latitude,
    double? longitude,
  }) {
    return OnboardingData(
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      reason: reason ?? this.reason,
      skills: skills ?? this.skills,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': fullName,
    'phone': phone,
    'reason': reason,
    'skills': skills,
    'location': location,
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
  };
}

class OnboardingNotifier extends StateNotifier<OnboardingData> {
  OnboardingNotifier() : super(const OnboardingData());

  void setFullName(String v) => state = state.copyWith(fullName: v);
  void setPhone(String v) => state = state.copyWith(phone: v);
  void setReason(String v) => state = state.copyWith(reason: v);
  void setLocation(String v) => state = state.copyWith(location: v);
  void setCoordinates(double lat, double lng) =>
      state = state.copyWith(latitude: lat, longitude: lng);

  void toggleSkill(String skill) {
    final current = List<String>.from(state.skills);
    if (current.contains(skill)) {
      current.remove(skill);
    } else {
      current.add(skill);
    }
    state = state.copyWith(skills: current);
  }

  void addCustomSkill(String skill) {
    if (skill.trim().isEmpty) return;
    final current = List<String>.from(state.skills);
    if (!current.contains(skill.trim())) {
      current.add(skill.trim());
    }
    state = state.copyWith(skills: current);
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingData>(
      (_) => OnboardingNotifier(),
    );
