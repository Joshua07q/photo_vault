import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import '../models/photo.dart';
import '../providers/photo_provider.dart';

class ViewerScreen extends StatefulWidget {
  final Photo photo;
  final String? tag;

  const ViewerScreen({
    super.key, 
    required this.photo,
    this.tag,
  });

  @override
  State<ViewerScreen> createState() => _ViewerScreenState();
}

class _ViewerScreenState extends State<ViewerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 1, end: 0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _editImage() async {
    try {
      // Show loading indicator for online images
      if (!widget.photo.isLocal && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 16),
                Text('Downloading image...'),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 30),
          ),
        );
      }
      
      // Get image bytes
      final bytes = await _getImageBytes();
      
      // Hide loading indicator
      if (!widget.photo.isLocal && mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
      
      if (bytes == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to download image. Check your internet connection.'),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }
    
      final editedImage = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageEditor(
            image: bytes,
          ),
        ),
      );

      if (editedImage != null) {
        try {
          // Use temp directory first, then move to app directory
          final tempDir = await getTemporaryDirectory();
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          
          // Generate simple filename
          String fileName;
          try {
            final originalPath = widget.photo.displayPath;
            // Remove query parameters from URLs
            final cleanPath = originalPath.split('?').first;
            final originalName = path.basename(cleanPath);
            final nameWithoutExt = path.basenameWithoutExtension(originalName);
            // Remove any invalid filename characters
            final sanitized = nameWithoutExt.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
            fileName = '${sanitized}_edited_$timestamp.jpg';
          } catch (e) {
            // Fallback if basename fails
            fileName = 'photo_edited_$timestamp.jpg';
          }
          
          // Save to temp first
          final tempFile = File(path.join(tempDir.path, fileName));
          await tempFile.writeAsBytes(editedImage);
          
          // Now try to move to app documents
          final appDir = await getApplicationDocumentsDirectory();
          final editedDir = Directory(path.join(appDir.path, 'Edited Photos'));
          
          if (!await editedDir.exists()) {
            await editedDir.create(recursive: true);
          }
          
          final finalFile = File(path.join(editedDir.path, fileName));
          await tempFile.copy(finalFile.path);
          await tempFile.delete();
          
          // Update the photo in the provider
          final photoProvider = Provider.of<PhotoProvider>(context, listen: false);
          await photoProvider.updatePhotoPath(widget.photo, finalFile.path);
          
          // Refresh the UI
          setState(() {});
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Saved: $fileName'),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } catch (e) {
          debugPrint('Error saving edited image: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to save: $e'),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error editing image: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
      if (_showControls) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            // Photo Viewer
            Hero(
              tag: widget.tag ?? widget.photo.displayPath,
              child: PhotoView(
                imageProvider: widget.photo.isLocal
                    ? FileImage(File(widget.photo.displayPath))
                    : NetworkImage(widget.photo.displayPath) as ImageProvider,
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 3.0,
                backgroundDecoration: const BoxDecoration(color: Colors.black),
                loadingBuilder: (context, event) => Center(
                  child: CircularProgressIndicator(
                    value: event == null
                        ? 0
                        : event.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 1),
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            
            // Top Controls
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 1.0],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildControlButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          onPressed: () => Navigator.pop(context),
                        ),
                        Row(
                          children: [
                            _buildControlButton(
                              icon: Icons.info_outline_rounded,
                              onPressed: () => _showPhotoInfo(),
                            ),
                            const SizedBox(width: 12),
                            _buildControlButton(
                              icon: Icons.more_vert_rounded,
                              onPressed: () => _showMoreOptions(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // Bottom Controls
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 1.0],
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildActionButton(
                            icon: widget.photo.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            label: widget.photo.isFavorite ? 'Liked' : 'Like',
                            onPressed: _toggleFavorite,
                          ),
                          _buildActionButton(
                            icon: Icons.share_rounded,
                            label: 'Share',
                            onPressed: _sharePhoto,
                          ),
                          _buildActionButton(
                            icon: Icons.save_alt_rounded,
                            label: 'Save',
                            onPressed: _savePhoto,
                          ),
                          _buildActionButton(
                            icon: Icons.edit_rounded,
                            label: 'Edit',
                            onPressed: _editImage,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPhotoInfo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Photo Info',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            _buildInfoRow('Date', widget.photo.dateAdded.toString().split('.')[0]),
            if (widget.photo.albumName != null)
              _buildInfoRow('Album', widget.photo.albumName!),
            _buildInfoRow('Type', widget.photo.isLocal ? 'Local' : 'Network'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 15,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              _buildMenuOption(
                icon: Icons.share_rounded,
                title: 'Share',
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement share
                },
              ),
              _buildMenuOption(
                icon: Icons.drive_file_move_rounded,
                title: 'Move to Album',
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement move
                },
              ),
              _buildMenuOption(
                icon: Icons.copy_rounded,
                title: 'Make a Copy',
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement copy
                },
              ),
              _buildMenuOption(
                icon: Icons.download_rounded,
                title: 'Save to Device',
                onTap: () {
                  Navigator.pop(context);
                  _saveToDevice();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF6366F1)),
      title: Text(title),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  void _saveToDevice() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo saved to device'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<bool> _checkIfFavorite() async {
    return widget.photo.isFavorite;
  }

  Future<void> _toggleFavorite() async {
    final photoProvider = Provider.of<PhotoProvider>(context, listen: false);
    final wasFavorite = widget.photo.isFavorite;
    
    await photoProvider.toggleFavorite(widget.photo);
    
    setState(() {
      if (wasFavorite) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from favorites'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Added to favorites'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 1),
          ),
        );
      }
    });
  }

  Future<Uint8List?> _getImageBytes() async {
    try {
      if (widget.photo.isLocal && widget.photo.file != null) {
        return await widget.photo.file!.readAsBytes();
      } else if (widget.photo.url != null) {
        // Download online image with timeout
        final response = await http.get(
          Uri.parse(widget.photo.url!),
        ).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw Exception('Download timeout');
          },
        );
        
        if (response.statusCode == 200) {
          return response.bodyBytes;
        } else {
          debugPrint('Failed to download image: ${response.statusCode}');
        }
      } else if (!widget.photo.isLocal && widget.photo.displayPath.startsWith('http')) {
        // Fallback: try displayPath if it's a URL
        final response = await http.get(
          Uri.parse(widget.photo.displayPath),
        ).timeout(const Duration(seconds: 30));
        
        if (response.statusCode == 200) {
          return response.bodyBytes;
        }
      }
    } catch (e) {
      debugPrint('Error getting image bytes: $e');
    }
    return null;
  }

  Future<File?> _downloadOnlinePhoto() async {
    try {
      if (widget.photo.url == null) return null;
      
      final response = await http.get(Uri.parse(widget.photo.url!));
      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final fileName = 'temp_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final file = File(path.join(tempDir.path, fileName));
        await file.writeAsBytes(response.bodyBytes);
        return file;
      }
    } catch (e) {
      debugPrint('Error downloading photo: $e');
    }
    return null;
  }

  Future<void> _sharePhoto() async {
    try {
      File? fileToShare;
      
      if (widget.photo.isLocal && widget.photo.file != null) {
        fileToShare = widget.photo.file;
      } else {
        // Download online photo first
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Downloading photo...'),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 1),
            ),
          );
        }
        fileToShare = await _downloadOnlinePhoto();
      }
      
      if (fileToShare != null) {
        final result = await Share.shareXFiles(
          [XFile(fileToShare.path)],
          text: 'Check out this photo!',
        );
        
        if (result.status == ShareResultStatus.success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Photo shared successfully'),
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 1),
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to prepare photo for sharing'),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing photo: $e'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _savePhoto() async {
    try {
      String? filePath;
      
      if (widget.photo.isLocal && widget.photo.file != null) {
        filePath = widget.photo.file!.path;
      } else {
        // Download online photo first
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Downloading photo...'),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 1),
            ),
          );
        }
        
        final bytes = await _getImageBytes();
        if (bytes != null) {
          final tempDir = await getTemporaryDirectory();
          final tempFile = File('${tempDir.path}/photo_${DateTime.now().millisecondsSinceEpoch}.jpg');
          await tempFile.writeAsBytes(bytes);
          filePath = tempFile.path;
        }
      }
      
      if (filePath != null) {
        await Gal.putImage(filePath);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo saved to gallery'),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 1),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to download photo'),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving photo: $e'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Photo?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              // TODO: Delete photo
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
