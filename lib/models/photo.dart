import 'dart:io';

class Photo {
  final String? id;
  final String? url;
  final File? file;
  final String? albumName;
  final DateTime dateAdded;
  final String? path;
  final String? userId;
  final bool isUploaded;
  final DateTime? lastModified;
  final Map<String, dynamic>? metadata;
  final bool isFavorite;
  final DateTime? timestamp;

  Photo({
    this.id,
    this.url,
    this.file,
    this.albumName,
    this.path,
    DateTime? dateAdded,
    this.userId,
    this.isUploaded = false,
    this.lastModified,
    this.metadata,
    this.isFavorite = false,
    this.timestamp,
  }) : dateAdded = dateAdded ?? DateTime.now(),
       assert(url != null || file != null, 'Either url or file must be provided');

  bool get isLocal => file != null;
  
  String get displayPath => file?.path ?? url ?? '';

  Photo copyWith({
    String? id,
    String? url,
    File? file,
    String? albumName,
    DateTime? dateAdded,
    String? path,
    String? userId,
    bool? isUploaded,
    DateTime? lastModified,
    Map<String, dynamic>? metadata,
    bool? isFavorite,
    DateTime? timestamp,
  }) {
    return Photo(
      id: id ?? this.id,
      url: url ?? this.url,
      file: file ?? this.file,
      albumName: albumName ?? this.albumName,
      dateAdded: dateAdded ?? this.dateAdded,
      path: path ?? this.path,
      userId: userId ?? this.userId,
      isUploaded: isUploaded ?? this.isUploaded,
      lastModified: lastModified ?? this.lastModified,
      metadata: metadata ?? this.metadata,
      isFavorite: isFavorite ?? this.isFavorite,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'url': url,
      'path': path,
      'albumName': albumName,
      'dateAdded': dateAdded.toIso8601String(),
      'isLocal': isLocal,
      'userId': userId,
      'isUploaded': isUploaded,
      'lastModified': lastModified?.toIso8601String(),
      'metadata': metadata,
      'isFavorite': isFavorite,
      'timestamp': timestamp?.toIso8601String(),
    };
  }

  static Photo fromMap(Map<String, dynamic> map) {
    return Photo(
      id: map['id'],
      url: map['url'],
      file: map['path'] != null ? File(map['path']) : null,
      albumName: map['albumName'],
      path: map['path'],
      dateAdded: DateTime.parse(map['dateAdded']),
      userId: map['userId'],
      isUploaded: map['isUploaded'] ?? false,
      lastModified: map['lastModified'] != null ? DateTime.parse(map['lastModified']) : null,
      metadata: map['metadata'],
      isFavorite: map['isFavorite'] ?? false,
      timestamp: map['timestamp'] != null ? DateTime.parse(map['timestamp']) : null,
    );
  }
}