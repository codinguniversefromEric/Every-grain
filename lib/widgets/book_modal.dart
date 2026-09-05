import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

Future<T?> showBookModal<T>(BuildContext context, {required String title, required Widget content}) {
  return showGeneralDialog<T>(
    context: context,
    pageBuilder: (context, animation, secondaryAnimation) {
      return _BookModalContent(
        title: title,
        content: content,
        animation: animation,
      );
    },
    barrierDismissible: true,
    barrierLabel: 'Close Book',
    barrierColor: Colors.black.withValues(alpha: 0.6),
    transitionDuration: const Duration(milliseconds: 800),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      // Add a slight scale and fade to the whole dialog
      final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curve,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(curve),
          child: child,
        ),
      );
    },
  );
}

class _BookModalContent extends StatefulWidget {
  final String title;
  final Widget content;
  final Animation<double> animation;

  const _BookModalContent({
    required this.title,
    required this.content,
    required this.animation,
  });

  @override
  State<_BookModalContent> createState() => _BookModalContentState();
}

class _BookModalContentState extends State<_BookModalContent> {
  @override
  Widget build(BuildContext context) {
    // The cover opens from 0 to -pi (180 degrees)
    // When angle > -pi/2, it shows the front cover.
    // When angle < -pi/2, it shows the inner content.
    
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 800),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: AnimatedBuilder(
            animation: widget.animation,
            builder: (context, child) {
              // We delay the opening slightly so the scale/fade happens first
              final openProgress = Interval(0.3, 1.0, curve: Curves.easeInOutCubic).transform(widget.animation.value);
              final angle = -openProgress * pi; // 0 to -180 degrees
              
              final isCoverVisible = angle >= -pi / 2;

              return Stack(
                children: [
                  // 1. The Back Cover / Inner Pages (always present, but revealed as cover opens)
                  // We only show it slightly when fully opened, or just treat it as the background for the content.
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4EAD5), // paperBackground
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(10, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        // The content itself
                        child: Material(
                          color: Colors.transparent,
                          child: Stack(
                            children: [
                              Positioned.fill(child: widget.content),
                              // A close button on the top right
                              Positioned(
                                top: 8,
                                right: 8,
                                child: IconButton(
                                  icon: const Icon(Icons.close, color: Color(0xFF5D4037)), // inkBlack
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 2. The Front Cover (hinged at the left edge)
                  Positioned.fill(
                    child: Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001) // perspective
                        ..rotateY(angle),
                      alignment: Alignment.centerLeft,
                      child: isCoverVisible
                          ? _buildCoverFront()
                          : _buildCoverBack(),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCoverFront() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF5A4A42), // Dark brown leather/vintage cover
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(5, 5),
          ),
        ],
        border: Border.all(color: const Color(0xFF3E322C), width: 2),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.eco, size: 64, color: Color(0xFFD4C4A8)),
            const SizedBox(height: 24),
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
                color: Color(0xFFD4C4A8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverBack() {
    // When the cover flips over 90 degrees, it shows its back.
    // We make it transparent or a flat page color so it doesn't obstruct the content.
    // Actually, if it opens 180 degrees, it will sit to the left of the hinge.
    // If we are on a phone, opening 180 degrees left would go off-screen!
    // Wait, on a phone, if the book is full width, a 180 degree left rotation goes entirely off screen to the left.
    // That's actually perfect! It flips open and gets out of the way!
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.rotationY(pi), // flip horizontally so it's not mirrored
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFE8E3D9), // Inner cover color
          borderRadius: BorderRadius.horizontal(left: Radius.circular(12)),
        ),
      ),
    );
  }
}
