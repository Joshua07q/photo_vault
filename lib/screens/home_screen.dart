import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/photo_provider.dart';
import '../providers/theme_provider.dart';
import '../models/photo.dart';
import '../widgets/network_image.dart';
import 'viewer_screen.dart';
import 'gallery_screen.dart';
import 'online_photos_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _selectedTab = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showAddPhotoOptions() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      _pickImages();
      return;
    }
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: AppTheme.cardShadow(context),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textSecondary(context).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text('Add Photos', style: AppTheme.titleStyle(context)),
              const SizedBox(height: 24),
              _buildOptionCard(
                icon: Icons.camera_alt_rounded,
                title: 'Take Photo',
                subtitle: 'Use your camera',
                gradient: AppTheme.gradientNeonStatic,
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
              const SizedBox(height: 12),
              _buildOptionCard(
                icon: Icons.photo_library_rounded,
                title: 'Choose from Gallery',
                subtitle: 'Select from your photos',
                gradient: AppTheme.gradientSilver,
                onTap: () {
                  Navigator.pop(context);
                  _pickImages();
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.neonBlue.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withOpacity(0.8),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _takePhoto() async {
    final photoProvider = Provider.of<PhotoProvider>(context, listen: false);
    await photoProvider.pickImage(fromCamera: true);
  }

  Future<void> _pickImages() async {
    final photoProvider = Provider.of<PhotoProvider>(context, listen: false);
    await photoProvider.pickMultipleImages();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PhotoProvider>(
      builder: (context, photoProvider, child) {
        final allPhotos = photoProvider.photos;
        final albums = photoProvider.albums;

        return Scaffold(
          backgroundColor: AppTheme.background(context),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 180,
                floating: false,
                pinned: true,
                elevation: 0,
                backgroundColor: AppTheme.background(context),
                actions: [
                  IconButton(
                    icon: Icon(
                      Theme.of(context).brightness == Brightness.dark
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                      color: AppTheme.textPrimary(context),
                    ),
                    onPressed: () {
                      Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                    },
                  ),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
                  title: Text(
                    'PhotoVault',
                    style: TextStyle(
                      color: AppTheme.textPrimary(context),
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.neonBlue.withOpacity(0.05),
                          AppTheme.neonBlueDark.withOpacity(0.05),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cardBackground(context),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppTheme.cardShadow(context),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildTabButton(
                            label: 'Gallery',
                            isSelected: _selectedTab == 0,
                            onTap: () => setState(() => _selectedTab = 0),
                          ),
                        ),
                        Expanded(
                          child: _buildTabButton(
                            label: 'Albums',
                            isSelected: _selectedTab == 1,
                            onTap: () => setState(() => _selectedTab = 1),
                          ),
                        ),
                        Expanded(
                          child: _buildTabButton(
                            label: 'Online',
                            isSelected: _selectedTab == 2,
                            onTap: () => setState(() => _selectedTab = 2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Search Bar (only for Gallery and Albums)
              if (_selectedTab != 2)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
                          hintText: 'Search photos...',
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
                ),

              // Loading indicator for device photos
              if (photoProvider.isLoadingDevicePhotos && _selectedTab != 2)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground(context),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppTheme.cardShadow(context),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.neonBlue,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Loading device photos...',
                            style: AppTheme.subtitleStyle(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              if (_selectedTab == 0)
                _buildGalleryView(allPhotos, photoProvider)
              else if (_selectedTab == 1)
                _buildAlbumsView(albums, photoProvider)
              else
                _buildOnlineView(),
            ],
          ),
          floatingActionButton: _selectedTab == 2 ? null : _buildFAB(),
        );
      },
    );
  }

  Widget _buildTabButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.gradientNeon(context) : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textSecondary(context),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildGalleryView(List<Photo> photos, PhotoProvider provider) {
    // Filter photos based on search query
    final filteredPhotos = _searchQuery.isEmpty
        ? photos
        : photos.where((photo) {
            final albumName = photo.albumName?.toLowerCase() ?? '';
            final path = photo.path?.toLowerCase() ?? '';
            final query = _searchQuery.toLowerCase();
            return albumName.contains(query) || path.contains(query);
          }).toList();

    if (photos.isEmpty) {
      return SliverFillRemaining(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildEmptyState(),
            const SizedBox(height: 24),
            if (!provider.isLoadingDevicePhotos)
              ElevatedButton.icon(
                onPressed: () => provider.loadDevicePhotos(),
                icon: const Icon(Icons.phone_android_rounded),
                label: const Text('Load Device Photos'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.neonBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildPhotoThumbnail(filteredPhotos[index], index),
          childCount: filteredPhotos.length,
        ),
      ),
    );
  }

  Widget _buildAlbumsView(Map<String, List<Photo>> albums, PhotoProvider provider) {
    final favoritePhotos = provider.favoritePhotos;
    
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        delegate: SliverChildListDelegate([
          _buildSpecialAlbum(
            icon: Icons.favorite_rounded,
            title: 'Favorites',
            count: favoritePhotos.length,
            gradient: LinearGradient(
              colors: [Colors.pink.shade400, Colors.red.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GalleryScreen(
                    title: 'Favorites',
                    isFavoritesView: true,
                  ),
                ),
              );
            },
          ),
          ...albums.entries.map((entry) => _buildAlbumCard(
            albumName: entry.key,
            photoCount: entry.value.length,
            coverPhoto: entry.value.first,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GalleryScreen(
                    title: entry.key,
                    photos: entry.value,
                  ),
                ),
              );
            },
          )),
        ]),
      ),
    );
  }

  Widget _buildOnlineView() {
    return const SliverFillRemaining(
      child: OnlinePhotosScreen(),
    );
  }

  Widget _buildPhotoThumbnail(Photo photo, int index) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ViewerScreen(photo: photo, tag: "photo$index"),
        ),
      ),
      child: Hero(
        tag: "photo$index",
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: NetworkImageWithLoading(
            imageUrl: photo.displayPath,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialAlbum({
    required IconData icon,
    required String title,
    required int count,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.buttonShadow(context),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 32),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$count photos',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlbumCard({
    required String albumName,
    required int photoCount,
    required Photo coverPhoto,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBackground(context),
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.cardShadow(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: NetworkImageWithLoading(
                  imageUrl: coverPhoto.displayPath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    albumName,
                    style: AppTheme.titleStyle(context).copyWith(fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$photoCount photos',
                    style: AppTheme.captionStyle(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: AppTheme.gradientNeon(context),
              shape: BoxShape.circle,
              boxShadow: AppTheme.buttonShadow(context),
            ),
            child: const Icon(
              Icons.photo_library_rounded,
              size: 64,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'No Photos Yet',
            style: AppTheme.headingStyle(context).copyWith(fontSize: 24),
          ),
          const SizedBox(height: 12),
          Text(
            'Add your first photo to get started',
            style: AppTheme.subtitleStyle(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.gradientNeon(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.buttonShadow(context),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showAddPhotoOptions,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_rounded, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                Text('Add Photos', style: AppTheme.buttonTextStyle),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
