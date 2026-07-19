class Medication {
  final String id;
  final String userId;
  final String name;
  final String dosage;
  final String timeSlot;
  final String medTime;
  bool isTaken;
  final DateTime? scheduledDate;
  final DateTime createdAt;
  DateTime? takenAt;

  Medication({
    required this.id,
    required this.userId,
    required this.name,
    this.dosage = '',
    required this.timeSlot,
    required this.medTime,
    this.isTaken = false,
    this.scheduledDate,
    DateTime? createdAt,
    this.takenAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'dosage': dosage,
      'timeSlot': timeSlot,
      'medTime': medTime,
      'isTaken': isTaken,
      'scheduledDate': scheduledDate,
      'createdAt': createdAt,
      'takenAt': takenAt,
    };
  }

  factory Medication.fromMap(Map<String, dynamic> map, String documentId) {
    return Medication(
      id: documentId,
      userId: map['userId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      dosage: map['dosage'] as String? ?? '',
      timeSlot: map['timeSlot'] as String? ?? '',
      medTime: map['medTime'] as String? ?? '',
      isTaken: map['isTaken'] as bool? ?? false,
      scheduledDate: (map['scheduledDate'] as dynamic)?.toDate(),
      createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      takenAt: (map['takenAt'] as dynamic)?.toDate(),
    );
  }

  Medication copyWith({
    String? id,
    String? userId,
    String? name,
    String? dosage,
    String? timeSlot,
    String? medTime,
    bool? isTaken,
    DateTime? scheduledDate,
    DateTime? createdAt,
    DateTime? takenAt,
  }) {
    return Medication(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      timeSlot: timeSlot ?? this.timeSlot,
      medTime: medTime ?? this.medTime,
      isTaken: isTaken ?? this.isTaken,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      createdAt: createdAt ?? this.createdAt,
      takenAt: takenAt ?? this.takenAt,
    );
  }
}
