import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/photo.dart';
import 'viewer_screen.dart';

class OnlinePhotosScreen extends StatefulWidget {
  const OnlinePhotosScreen({super.key});

  @override
  State<OnlinePhotosScreen> createState() => _OnlinePhotosScreenState();
}

class _OnlinePhotosScreenState extends State<OnlinePhotosScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  // Sample online photos from Unsplash
  final List<Map<String, String>> _samplePhotos = [
    {'url': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4', 'title': 'Mountain'},
    {'url': 'https://images.unsplash.com/photo-1469474968028-56623f02e42e', 'title': 'Nature'},
    {'url': 'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05', 'title': 'Sunset'},
    {'url': 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e', 'title': 'Forest'},
    {'url': 'https://images.unsplash.com/photo-1426604966848-d7adac402bff', 'title': 'Lake'},
    {'url': 'https://images.unsplash.com/photo-1472214103451-9374bd1c798e', 'title': 'Beach'},
    {'url': 'https://images.unsplash.com/photo-1501594907352-04cda38ebc29', 'title': 'Ocean'},
    {'url': 'https://images.unsplash.com/photo-1518173946687-a4c8892bbd9f', 'title': 'Desert'},
  ];
  
  final List<Map<String, dynamic>> _cloudServices = [
    {
      'name': 'Google Photos',
      'icon': Icons.photo_library_rounded,
      'color': const Color(0xFF4285F4),
      'connected': false,
    },
    {
      'name': 'iCloud',
      'icon': Icons.cloud_rounded,
      'color': const Color(0xFF007AFF),
      'connected': false,
    },
    {
      'name': 'Dropbox',
      'icon': Icons.folder_rounded,
      'color': const Color(0xFF0061FF),
      'connected': false,
    },
    {
      'name': 'OneDrive',
      'icon': Icons.cloud_circle_rounded,
      'color': const Color(0xFF0078D4),
      'connected': false,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, String>> get _filteredPhotos {
    if (_searchQuery.isEmpty) return _samplePhotos;
    return _samplePhotos
        .where((photo) => photo['title']!.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.cardBackground(context),
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppTheme.cardShadow(context),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search online photos...',
                hintStyle: AppTheme.subtitleStyle(context),
                prefixIcon: Icon(Icons.search_rounded, color: AppTheme.neonBlue),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear_rounded, color: AppTheme.textSecondary(context)),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
        ),
        
        // Online Photos Grid
        Expanded(
          child: _filteredPhotos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 64,
                        color: AppTheme.textSecondary(context).withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No photos found',
                        style: AppTheme.titleStyle(context),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: _filteredPhotos.length,
                  itemBuilder: (context, index) {
                    final photo = _filteredPhotos[index];
                    return _buildPhotoCard(photo);
                  },
                ),
        ),
        
        // Cloud Services Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardBackground(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Connect Cloud Services',
                style: AppTheme.titleStyle(context).copyWith(fontSize: 16),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _cloudServices.map((service) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: _buildServiceChip(
                        name: service['name'],
                        icon: service['icon'],
                        color: service['color'],
                        connected: service['connected'],
                        onTap: () => _connectService(_cloudServices.indexOf(service)),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoCard(Map<String, String> photo) {
    return GestureDetector(
      onTap: () {
        // Open photo viewer with online photo
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewerScreen(
              photo: Photo(
                url: '${photo['url']}?w=1920&h=1080&fit=crop',
                id: photo['url'],
                albumName: 'Online',
              ),
              tag: photo['url'],
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.cardShadow(context),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                '${photo['url']}?w=400&h=600&fit=crop',
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: AppTheme.cardBackground(context),
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        color: AppTheme.neonBlue,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppTheme.cardBackground(context),
                    child: Icon(
                      Icons.broken_image_rounded,
                      color: AppTheme.textSecondary(context),
                      size: 48,
                    ),
                  );
                },
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Text(
                    photo['title']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceChip({
    required String name,
    required IconData icon,
    required Color color,
    required bool connected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: connected ? color.withOpacity(0.1) : AppTheme.cardBackground(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: connected ? color : AppTheme.textSecondary(context).withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              name,
              style: TextStyle(
                color: AppTheme.textPrimary(context),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required String name,
    required IconData icon,
    required Color color,
    required bool connected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow(context),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTheme.titleStyle(context).copyWith(fontSize: 17),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        connected ? 'Connected' : 'Not connected',
                        style: AppTheme.captionStyle(context).copyWith(
                          color: connected ? AppTheme.neonBlue : AppTheme.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: connected ? null : AppTheme.gradientNeonStatic,
                    color: connected ? AppTheme.silver.withOpacity(0.2) : null,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    connected ? 'Disconnect' : 'Connect',
                    style: TextStyle(
                      color: connected ? AppTheme.textSecondary(context) : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _connectService(int index) {
    setState(() {
      _cloudServices[index]['connected'] = !_cloudServices[index]['connected'];
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _cloudServices[index]['connected']
              ? '${_cloudServices[index]['name']} connected!'
              : '${_cloudServices[index]['name']} disconnected',
        ),
        backgroundColor: AppTheme.neonBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
