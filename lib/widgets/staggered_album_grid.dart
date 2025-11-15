import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class StaggeredAlbumGrid extends StatelessWidget {
  final int crossAxisCount;
  final double spacing;
  final double runSpacing;
  final List<Widget> children;

  const StaggeredAlbumGrid({
    super.key,
    this.crossAxisCount = 2,
    this.spacing = 16,
    this.runSpacing = 16,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return AnimationLimiter(
      child: MasonryGridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: spacing,
        crossAxisSpacing: runSpacing,
        itemCount: children.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 375),
            columnCount: crossAxisCount,
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: children[index],
              ),
            ),
          );
        },
      ),
    );
  }
}