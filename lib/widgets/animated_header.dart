import 'dart:ui';
import 'package:flutter/material.dart';

class CustomHeader extends SliverPersistentHeaderDelegate {
  @override
  final double minExtent;
  @override
  final double maxExtent;

  CustomHeader({required this.minExtent, required this.maxExtent});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final progress = shrinkOffset / (maxExtent - minExtent);

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('assets/header_bg.jpg', fit: BoxFit.cover),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8 * progress, sigmaY: 8 * progress),
            child: Container(color: Color.fromRGBO(0, 0, 0, (0.2 + progress * 0.3).clamp(0.0, 1.0))),
          ),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'My PhotoVault',
              style: TextStyle(
                fontSize: 32 - 10 * progress,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool shouldRebuild(CustomHeader oldDelegate) => true;
}
