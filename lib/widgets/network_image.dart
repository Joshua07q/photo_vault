import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NetworkImageWithLoading extends StatelessWidget {
  final String imageUrl;
  final BoxFit? fit;
  final BorderRadius? borderRadius;
  
  const NetworkImageWithLoading({
    super.key,
    required this.imageUrl,
    this.fit,
    this.borderRadius,
  });

  bool _isLocalFile(String path) {
    return File(path).existsSync();
  }

  bool _isNetworkUrl(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: _isLocalFile(imageUrl)
          ? Image.file(
              File(imageUrl),
              fit: fit ?? BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildErrorWidget();
              },
            )
          : _isNetworkUrl(imageUrl)
              ? Image.network(
                  imageUrl,
                  fit: fit ?? BoxFit.cover,
                  frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                    if (wasSynchronouslyLoaded) return child;
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: frame != null
                          ? child
                          : Container(
                              color: Colors.black.withOpacity(0.03),
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.neonBlue.withOpacity(0.5),
                                ),
                              ),
                            ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return _buildErrorWidget();
                  },
                )
              : _buildErrorWidget(),
    );
  }

  Widget _buildErrorWidget() {
    return Builder(
      builder: (context) => Container(
        color: Colors.black.withOpacity(0.03),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image_outlined,
              color: AppTheme.textSecondary(context).withOpacity(0.4),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'Image not available',
              style: TextStyle(
                color: AppTheme.textSecondary(context).withOpacity(0.4),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}