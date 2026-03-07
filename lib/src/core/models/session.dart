import 'mantra.dart';

class Session {
  final String id;
  final String mantraId;
  final String mantraTitle;
  final int repsCompleted;
  final int targetReps;
  final RepetitionCycle targetCycle;
  final int duration; // seconds
  final DateTime startTime;
  final bool completed;

  const Session({
    required this.id,
    required this.mantraId,
    required this.mantraTitle,
    required this.repsCompleted,
    required this.targetReps,
    this.targetCycle = RepetitionCycle.session,
    required this.duration,
    required this.startTime,
    required this.completed,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'mantraId': mantraId,
    'mantraTitle': mantraTitle,
    'repsCompleted': repsCompleted,
    'targetReps': targetReps,
    'targetCycle': targetCycle.name,
    'duration': duration,
    'startTime': startTime.toIso8601String(),
    'completed': completed,
  };

  factory Session.fromJson(Map<String, dynamic> j) => Session(
    id: j['id'] as String,
    mantraId: j['mantraId'] as String,
    mantraTitle: j['mantraTitle'] as String,
    repsCompleted: j['repsCompleted'] as int,
    targetReps: j['targetReps'] as int,
    targetCycle: RepetitionCycle.values.firstWhere(
      (e) => e.name == j['targetCycle'],
      orElse: () => RepetitionCycle.session,
    ),
    duration: j['duration'] as int,
    startTime: DateTime.parse(j['startTime'] as String),
    completed: j['completed'] as bool,
  );
}
