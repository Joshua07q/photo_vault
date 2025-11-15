import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/photo.dart';

class PhotoRepository {
  final StreamController<List<Photo>> _photosController = StreamController<List<Photo>>.broadcast();
  final List<Photo> _photos = [];

  PhotoRepository() {
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    final prefs = await SharedPreferences.getInstance();
    final photoData = prefs.getStringList('photos') ?? [];
    
    _photos.clear();
    for (var data in photoData) {
      try {
        final parts = data.split('|');
        if (parts.length >= 3) {
          final file = File(parts[0]);
          if (await file.exists()) {
            _photos.add(Photo(
              id: parts[1],
              file: file,
              path: parts[0],
              albumName: parts[2],
              dateAdded: DateTime.parse(parts[3]),
            ));
          }
        }
      } catch (e) {
        print('Error loading photo: $e');
      }
    }
    
    _photosController.add(_photos);
  }

  Future<void> _savePhotos() async {
    final prefs = await SharedPreferences.getInstance();
    final photoData = _photos.map((p) => 
      '${p.path}|${p.id}|${p.albumName ?? "Unsorted"}|${p.dateAdded.toIso8601String()}'
    ).toList();
    await prefs.setStringList('photos', photoData);
  }

  Future<Photo> uploadPhoto(Photo photo) async {
    if (!photo.isLocal) return photo;

    try {
      final appDir = await getApplicationDocumentsDirectory();
      var fileName = photo.file!.path.split(Platform.pathSeparator).last;
      
      // Clean up filename - remove .trash extension if present
      if (fileName.endsWith('.trash')) {
        fileName = fileName.substring(0, fileName.length - 6);
      }
      
      // Ensure proper extension
      if (!fileName.toLowerCase().endsWith('.jpg') && 
          !fileName.toLowerCase().endsWith('.jpeg') && 
          !fileName.toLowerCase().endsWith('.png') &&
          !fileName.toLowerCase().endsWith('.gif') &&
          !fileName.toLowerCase().endsWith('.webp')) {
        fileName = '$fileName.jpg';
      }
      
      final albumDir = Directory('${appDir.path}${Platform.pathSeparator}photos${Platform.pathSeparator}${photo.albumName ?? "Unsorted"}');
      
      await albumDir.create(recursive: true);
      
      final newPath = '${albumDir.path}${Platform.pathSeparator}$fileName';
      final newFile = File(newPath);
      await photo.file!.copy(newPath);

      final newPhoto = Photo(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        file: newFile,
        path: newPath,
        albumName: photo.albumName,
        dateAdded: photo.dateAdded,
        isUploaded: true,
      );

      _photos.add(newPhoto);
      await _savePhotos();
      _photosController.add(_photos);
      
      return newPhoto;
    } catch (e) {
      print('Error uploading photo: $e');
      // If copy fails, just add the original photo
      final newPhoto = Photo(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        file: photo.file,
        path: photo.path,
        albumName: photo.albumName,
        dateAdded: photo.dateAdded,
        isUploaded: false,
      );
      
      _photos.add(newPhoto);
      await _savePhotos();
      _photosController.add(_photos);
      
      return newPhoto;
    }
  }

  Stream<List<Photo>> getPhotos({String? albumName}) {
    if (albumName != null) {
      return _photosController.stream.map((photos) => 
        photos.where((p) => p.albumName == albumName).toList()
      );
    }
    return _photosController.stream;
  }

  Stream<Map<String, List<Photo>>> getAlbums() {
    return _photosController.stream.map((photos) {
      final albums = <String, List<Photo>>{};
      for (final photo in photos) {
        final albumName = photo.albumName ?? 'Unsorted';
        albums.putIfAbsent(albumName, () => []).add(photo);
      }
      return albums;
    });
  }

  Future<void> deletePhoto(Photo photo) async {
    _photos.remove(photo);
    
    if (photo.file != null && await photo.file!.exists()) {
      await photo.file!.delete();
    }
    
    await _savePhotos();
    _photosController.add(_photos);
  }

  Future<void> movePhotoToAlbum(Photo photo, String newAlbumName) async {
    final index = _photos.indexWhere((p) => p.id == photo.id);
    if (index != -1) {
      final oldPhoto = _photos[index];
      final newPhoto = Photo(
        id: oldPhoto.id,
        file: oldPhoto.file,
        path: oldPhoto.path,
        albumName: newAlbumName,
        dateAdded: oldPhoto.dateAdded,
        isUploaded: oldPhoto.isUploaded,
      );
      _photos[index] = newPhoto;
      await _savePhotos();
      _photosController.add(_photos);
    }
  }

  Future<void> updatePhotoMetadata(Photo photo, Map<String, dynamic> metadata) async {
    // Metadata updates can be implemented if needed
  }

  Future<int> getCachedSize() async {
    return 0;
  }

  Future<void> clearCache() async {
    // No cache to clear in local-only mode
  }

  Future<void> toggleFavorite(Photo photo) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];
    
    if (favorites.contains(photo.id)) {
      favorites.remove(photo.id);
    } else {
      favorites.add(photo.id!);
    }
    
    await prefs.setStringList('favorites', favorites);
  }

  Future<bool> isFavorite(String photoId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];
    return favorites.contains(photoId);
  }

  Future<List<Photo>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];
    return _photos.where((p) => favorites.contains(p.id)).toList();
  }

  Future<void> savePreferences(Map<String, dynamic> prefs) async {
    final sharedPrefs = await SharedPreferences.getInstance();
    for (final entry in prefs.entries) {
      if (entry.value is bool) {
        await sharedPrefs.setBool(entry.key, entry.value);
      } else if (entry.value is String) {
        await sharedPrefs.setString(entry.key, entry.value);
      } else if (entry.value is int) {
        await sharedPrefs.setInt(entry.key, entry.value);
      } else if (entry.value is double) {
        await sharedPrefs.setDouble(entry.key, entry.value);
      }
    }
  }

  Future<Map<String, dynamic>> getPreferences() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    return sharedPrefs.getKeys().fold<Map<String, dynamic>>({}, (map, key) {
      map[key] = sharedPrefs.get(key);
      return map;
    });
  }

  void dispose() {
    _photosController.close();
  }
}
