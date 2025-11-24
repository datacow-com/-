import 'package:flutter/foundation.dart';

class Script {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime lastModified;
  final List<String> tags;
  final bool isFavorite;

  const Script({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.lastModified,
    this.tags = const [],
    this.isFavorite = false,
  });

  Script copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? lastModified,
    List<String>? tags,
    bool? isFavorite,
  }) {
    return Script(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'lastModified': lastModified.toIso8601String(),
      'tags': tags,
      'isFavorite': isFavorite,
    };
  }

  factory Script.fromJson(Map<String, dynamic> json) {
    return Script(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastModified: DateTime.parse(json['lastModified'] as String),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Script &&
      other.id == id &&
      other.title == title &&
      other.content == content &&
      other.createdAt == createdAt &&
      other.lastModified == lastModified &&
      listEquals(other.tags, tags) &&
      other.isFavorite == isFavorite;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      title.hashCode ^
      content.hashCode ^
      createdAt.hashCode ^
      lastModified.hashCode ^
      tags.hashCode ^
      isFavorite.hashCode;
  }
}
