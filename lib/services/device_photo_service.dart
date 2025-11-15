import 'dart:io';
import 'package:photo_manager/photo_manager.dart';
import '../models/photo.dart';

class DevicePhotoService {
  static Future<bool> requestPermissions() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    return ps.isAuth || ps.hasAccess;
  }

  static Future<List<Photo>> loadDevicePhotos({int page = 0, int pageSize = 100}) async {
    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      return [];
    }

    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      hasAll: true,
    );

    if (albums.isEmpty) return [];

    final List<Photo> photos = [];
    
    for (var album in albums) {
      final List<AssetEntity> assets = await album.getAssetListPaged(
        page: page,
        size: pageSize,
      );

      for (var asset in assets) {
        final file = await asset.file;
        if (file != null) {
          photos.add(Photo(
            file: file,
            path: file.path,
            albumName: album.name,
            timestamp: asset.createDateTime,
          ));
        }
      }
    }

    return photos;
  }

  static Future<Map<String, List<Photo>>> loadDeviceAlbums() async {
    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      return {};
    }

    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      hasAll: false,
    );

    final Map<String, List<Photo>> albumMap = {};

    for (var album in albums) {
      final List<AssetEntity> assets = await album.getAssetListPaged(
        page: 0,
        size: 100,
      );

      final List<Photo> photos = [];
      for (var asset in assets) {
        final file = await asset.file;
        if (file != null) {
          photos.add(Photo(
            file: file,
            path: file.path,
            albumName: album.name,
            timestamp: asset.createDateTime,
          ));
        }
      }

      if (photos.isNotEmpty) {
        albumMap[album.name] = photos;
      }
    }

    return albumMap;
  }

  static Future<int> getTotalPhotoCount() async {
    final hasPermission = await requestPermissions();
    if (!hasPermission) return 0;

    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      hasAll: true,
    );

    if (albums.isEmpty) return 0;

    return await albums.first.assetCountAsync;
  }
}
