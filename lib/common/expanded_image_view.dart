// lib/screens/expanded_image_view.dart

import 'package:flutter/material.dart';

class ExpandedImageViewScreen extends StatelessWidget {
  final String imageUrl;
  final String heroTag;

  const ExpandedImageViewScreen({
    super.key,
    required this.imageUrl,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ), // Back button color
      ),
      body: Center(
        // InteractiveViewer allows for pinch-to-zoom and panning.
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 4.0,
          child: Hero(
            // The tag must match the one in the message bubble.
            tag: heroTag,
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              // Show a loading indicator while the full-resolution image loads.
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
