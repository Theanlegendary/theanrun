import 'package:flutter/foundation.dart';

class AudioMetadata {
  final String id;
  final String title;
  final String category;
  final String audioUrl;
  final String imageUrl;
  final String type; // 'sound', 'meditation', 'sleep', 'playlist'
  final int durationMins;
  final double defaultVolume;
  final bool isFeatured;
  final bool isPublished;
  final int version;

  AudioMetadata({
    required this.id,
    required this.title,
    required this.category,
    required this.audioUrl,
    required this.imageUrl,
    required this.type,
    this.durationMins = 0,
    this.defaultVolume = 0.5,
    this.isFeatured = false,
    this.isPublished = true,
    this.version = 1,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'audioUrl': audioUrl,
        'imageUrl': imageUrl,
        'type': type,
        'durationMins': durationMins,
        'defaultVolume': defaultVolume,
        'isFeatured': isFeatured,
        'isPublished': isPublished,
        'version': version,
      };

  factory AudioMetadata.fromJson(Map<String, dynamic> json) => AudioMetadata(
        id: json['id'] as String,
        title: json['title'] as String,
        category: json['category'] as String,
        audioUrl: json['audioUrl'] as String,
        imageUrl: json['imageUrl'] as String,
        type: json['type'] as String,
        durationMins: json['durationMins'] as int? ?? 0,
        defaultVolume: (json['defaultVolume'] as num?)?.toDouble() ?? 0.5,
        isFeatured: json['isFeatured'] as bool? ?? false,
        isPublished: json['isPublished'] as bool? ?? true,
        version: json['version'] as int? ?? 1,
      );
}

class CmsService {
  static final CmsService _instance = CmsService._internal();
  factory CmsService() => _instance;
  CmsService._internal();

  final List<AudioMetadata> _items = [
    AudioMetadata(
      id: 'rain',
      title: 'Soft Rain',
      category: 'Nature',
      audioUrl: 'https://cdn.pixabay.com/download/audio/2021/09/06/audio_8b211a7c5b.mp3',
      imageUrl: 'https://images.unsplash.com/photo-1519692933481-e162a57d6721',
      type: 'sound',
      defaultVolume: 0.7,
      isFeatured: true,
    ),
    AudioMetadata(
      id: 'ocean',
      title: 'Ocean Waves',
      category: 'Nature',
      audioUrl: 'https://cdn.pixabay.com/download/audio/2022/03/15/audio_c8c8a7092b.mp3',
      imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e',
      type: 'sound',
      defaultVolume: 0.6,
      isFeatured: true,
    ),
    AudioMetadata(
      id: 'meditation-morning',
      title: 'Morning Clarity',
      category: 'Morning Energy',
      audioUrl: 'https://cdn.pixabay.com/download/audio/2022/05/16/audio_db6591201e.mp3',
      imageUrl: 'https://images.unsplash.com/photo-1470240731273-7821a6eeb6bd',
      type: 'meditation',
      durationMins: 10,
      isFeatured: true,
    ),
    AudioMetadata(
      id: 'sleep-alpine',
      title: 'Midnight Alpine Forest',
      category: 'Nature Sanctuary',
      audioUrl: 'https://cdn.pixabay.com/download/audio/2022/10/25/audio_946b5a329d.mp3',
      imageUrl: 'https://images.unsplash.com/photo-1448375240586-882707db888b',
      type: 'sleep',
      durationMins: 25,
      isFeatured: true,
    ),
  ];

  List<AudioMetadata> get items => List.unmodifiable(_items);

  // Realtime Broadcast Notifier for Instant Live Synchronization
  final ValueNotifier<int> catalogNotifier = ValueNotifier<int>(0);

  // Anonymous Public App Access (No Login Required)
  Future<List<AudioMetadata>> fetchPublicCatalog() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _items.where((i) => i.isPublished).toList();
  }

  // Admin CMS CRUD (Admin Privileges)
  void publishNewItem(AudioMetadata item) {
    _items.add(item);
    catalogNotifier.value++;
    debugPrint('CMS: Published new dynamic audio item ${item.title}');
  }

  void updateItem(AudioMetadata updated) {
    final idx = _items.indexWhere((i) => i.id == updated.id);
    if (idx != -1) {
      _items[idx] = updated;
      catalogNotifier.value++;
    }
  }

  void deleteItem(String id) {
    _items.removeWhere((i) => i.id == id);
    catalogNotifier.value++;
  }
}
