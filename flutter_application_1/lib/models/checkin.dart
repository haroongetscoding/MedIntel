class Checkin {
  final String id;
  final String userId;
  final String dateKey;
  final int moodScore;
  final String moodLabel;
  final List<String> symptoms;
  final String notes;
  final DateTime createdAt;

  Checkin({
    required this.id,
    required this.userId,
    required this.dateKey,
    required this.moodScore,
    required this.moodLabel,
    this.symptoms = const [],
    this.notes = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'dateKey': dateKey,
      'moodScore': moodScore,
      'moodLabel': moodLabel,
      'symptoms': symptoms,
      'notes': notes,
      'createdAt': createdAt,
    };
  }

  factory Checkin.fromMap(Map<String, dynamic> map, String documentId) {
    return Checkin(
      id: documentId,
      userId: map['userId'] as String? ?? '',
      dateKey: map['dateKey'] as String? ?? '',
      moodScore: map['moodScore'] as int? ?? 5,
      moodLabel: map['moodLabel'] as String? ?? 'Good',
      symptoms: (map['symptoms'] as List<dynamic>?)?.cast<String>() ?? [],
      notes: map['notes'] as String? ?? '',
      createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }
}
