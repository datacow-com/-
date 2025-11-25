class SpeechHistory {
  final int? id;
  final DateTime timestamp;
  final int durationSeconds;
  final int wordCount;
  final int score;
  final String scriptTitle;
  final double ktvDeviation;

  SpeechHistory({
    this.id,
    required this.timestamp,
    required this.durationSeconds,
    required this.wordCount,
    required this.score,
    required this.scriptTitle,
    required this.ktvDeviation,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'duration_seconds': durationSeconds,
      'word_count': wordCount,
      'score': score,
      'script_title': scriptTitle,
      'ktv_deviation': ktvDeviation,
    };
  }

  factory SpeechHistory.fromMap(Map<String, dynamic> map) {
    return SpeechHistory(
      id: map['id'] as int?,
      timestamp: DateTime.parse(map['timestamp'] as String),
      durationSeconds: map['duration_seconds'] as int,
      wordCount: map['word_count'] as int,
      score: map['score'] as int,
      scriptTitle: map['script_title'] as String,
      ktvDeviation: (map['ktv_deviation'] as num).toDouble(),
    );
  }
}
