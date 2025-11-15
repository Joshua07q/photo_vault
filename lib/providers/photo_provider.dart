import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/photo.dart';
import '../repositories/photo_repository.dart';
import '../services/device_photo_service.dart';
import '../services/favorites_service.dart';

class PhotoProvider extends ChangeNotifier {
  final PhotoRepository _repository;
  final ImagePicker _picker = ImagePicker();
  List<Photo> _photos = [];
  Map<String, List<Photo>> _albums = {};
  bool _initialized = false;
  bool _isLoadingDevicePhotos = false;
  Set<String> _favoritePaths = {};

  PhotoProvider({PhotoRepository? repository}) 
      : _repository = repository ?? PhotoRepository() {
    _initialize();
  }

  List<Photo> get photos => List.unmodifiable(_photos);
  Map<String, List<Photo>> get albums => Map.unmodifiable(_albums);
  bool get isLoadingDevicePhotos => _isLoadingDevicePhotos;
  List<Photo> get favoritePhotos => _photos.where((p) => p.isFavorite).toList();

  Future<void> _initialize() async {
    if (_initialized) return;
    
    // Load favorites first
    _favoritePaths = await FavoritesService.loadFavorites();
    
    // Load from repository first
    _repository.getPhotos().listen((photos) {
      _photos = _applyFavorites(photos);
      notifyListeners();
    });

    _repository.getAlbums().listen((albums) {
      _albums = albums;
      notifyListeners();
    });
    
    // Then load device photos
    await loadDevicePhotos();
    
    _initialized = true;
  }

  List<Photo> _applyFavorites(List<Photo> photos) {
    return photos.map((photo) {
      final isFav = _favoritePaths.contains(photo.displayPath);
      return photo.copyWith(isFavorite: isFav);
    }).toList();
  }

  Future<void> loadDevicePhotos() async {
    _isLoadingDevicePhotos = true;
    notifyListeners();

    try {
      // Only load device photos on mobile platforms
      if (Platform.isAndroid || Platform.isIOS) {
        final devicePhotos = await DevicePhotoService.loadDevicePhotos();
        final deviceAlbums = await DevicePhotoService.loadDeviceAlbums();
        
        // Merge device photos with existing photos (avoid duplicates)
        final existingPaths = _photos.map((p) => p.path).toSet();
        final newPhotos = _applyFavorites(
          devicePhotos.where((p) => !existingPaths.contains(p.path)).toList()
        );
        
        _photos.addAll(newPhotos);
        
        // Merge albums
        deviceAlbums.forEach((albumName, photos) {
          final favPhotos = _applyFavorites(photos);
          if (_albums.containsKey(albumName)) {
            final existingAlbumPaths = _albums[albumName]!.map((p) => p.path).toSet();
            final newAlbumPhotos = favPhotos.where((p) => !existingAlbumPaths.contains(p.path)).toList();
            _albums[albumName]!.addAll(newAlbumPhotos);
          } else {
            _albums[albumName] = favPhotos;
          }
        });
      }
      
    } catch (e) {
      debugPrint('Error loading device photos: $e');
    } finally {
      _isLoadingDevicePhotos = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(Photo photo) async {
    final photoPath = photo.displayPath;
    
    // Toggle in memory
    if (_favoritePaths.contains(photoPath)) {
      _favoritePaths.remove(photoPath);
    } else {
      _favoritePaths.add(photoPath);
    }
    
    // Update the photo object
    final index = _photos.indexWhere((p) => p.displayPath == photoPath);
    if (index != -1) {
      _photos[index] = _photos[index].copyWith(isFavorite: !_photos[index].isFavorite);
    }
    
    // Update in albums
    _albums.forEach((albumName, photos) {
      final albumIndex = photos.indexWhere((p) => p.displayPath == photoPath);
      if (albumIndex != -1) {
        photos[albumIndex] = photos[albumIndex].copyWith(isFavorite: !photos[albumIndex].isFavorite);
      }
    });
    
    // Persist to storage
    await FavoritesService.toggleFavorite(photoPath);
    
    notifyListeners();
  }

  Future<void> pickImage({bool fromCamera = false}) async {
    final XFile? image = await _picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
    );

    if (image != null) {
      final photo = Photo(
        file: File(image.path),
        path: image.path,
        albumName: fromCamera ? 'Camera' : _getAlbumNameFromPath(image.path),
      );
      
      await _repository.uploadPhoto(photo);
      // Don't add here - repository already adds and notifies
    }
  }

  Future<void> pickMultipleImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    
    for (var image in images) {
      final photo = Photo(
        file: File(image.path),
        path: image.path,
        albumName: _getAlbumNameFromPath(image.path),
      );
      
      await _repository.uploadPhoto(photo);
      // Don't add here - repository already adds and notifies
    }
  }

  void _addToAlbum(Photo photo) {
    final albumName = photo.albumName ?? 'Unsorted';
    _albums.putIfAbsent(albumName, () => []);
    _albums[albumName]!.add(photo);
  }

  String _getAlbumNameFromPath(String path) {
    final directory = path.split(Platform.pathSeparator);
    if (directory.length < 2) return 'Gallery';
    return directory[directory.length - 2];
  }

  Future<List<Photo>> getAlbumPhotos(String albumName) async {
    return (await _repository.getPhotos(albumName: albumName).first);
  }

  Future<void> deletePhoto(Photo photo) async {
    await _repository.deletePhoto(photo);
    _photos.remove(photo);
    if (photo.albumName != null) {
      _albums[photo.albumName]?.remove(photo);
    }
    notifyListeners();
  }

  Future<void> movePhotoToAlbum(Photo photo, String newAlbumName) async {
    await _repository.movePhotoToAlbum(photo, newAlbumName);
  }

  Future<void> updatePhotoMetadata(Photo photo, Map<String, dynamic> metadata) async {
    await _repository.updatePhotoMetadata(photo, metadata);
  }

  Future<void> clearCache() async {
    await _repository.clearCache();
  }

  Future<int> getCacheSize() async {
    return _repository.getCachedSize();
  }

  Future<Map<String, dynamic>> getPreferences() async {
    return _repository.getPreferences();
  }

  Future<void> savePreferences(Map<String, dynamic> prefs) async {
    await _repository.savePreferences(prefs);
  }

  Future<void> updatePhotoPath(Photo photo, String newPath) async {
    // Find and update the photo in the main list
    final index = _photos.indexWhere((p) => p.displayPath == photo.displayPath);
    if (index != -1) {
      _photos[index] = _photos[index].copyWith(
        path: newPath,
        file: File(newPath),
      );
    }
    
    // Update in albums
    if (photo.albumName != null && _albums.containsKey(photo.albumName)) {
      final albumIndex = _albums[photo.albumName]!.indexWhere((p) => p.displayPath == photo.displayPath);
      if (albumIndex != -1) {
        _albums[photo.albumName]![albumIndex] = _albums[photo.albumName]![albumIndex].copyWith(
          path: newPath,
          file: File(newPath),
        );
      }
    }
    
    notifyListeners();
  }
}