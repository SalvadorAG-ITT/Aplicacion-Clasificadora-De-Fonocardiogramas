import 'package:flutter/material.dart';

/// A widget that displays an iPhone 14/15 Pro screen layout.
///
/// This widget creates a screen with a light gray header, centered image,
/// and light gray footer, matching the design specifications.
class IPhone1415ProScreen extends StatelessWidget {
  /// The image URL to display in the center of the screen.
  final String imageUrl;

  /// Creates an iPhone 14/15 Pro screen widget.
  ///
  /// The [imageUrl] parameter is required and specifies the image to display.
  const IPhone1415ProScreen({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header area
              Container(
                color: const Color(0xFFF5F5F5), // rgba(245, 245, 245, 1)
                height: 70,
                width: double.infinity,
              ),

              // Spacer before image
              const SizedBox(height: 212),

              // Centered image
              Center(
                child: AspectRatio(
                  aspectRatio: 0.97,
                  child: SizedBox(
                    width: 258,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 48,
                            ),
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value:
                                loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Spacer after image
              const SizedBox(height: 237),

              // Footer area
              Container(
                color: const Color(0xFFF5F5F5), // rgba(245, 245, 245, 1)
                height: 66,
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
