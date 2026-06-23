import 'package:flutter/material.dart';

/// A network image with graceful loading and error states.
///
/// Wraps [Image.network] so that, instead of throwing the
/// "HTTP request failed, statusCode: ..." error and showing a broken box
/// when a photo URL is unreachable (offline, 404, or rate-limited), it shows
/// a neutral placeholder with a small icon. A spinner is shown while the
/// image is downloading.
///
/// Used everywhere the app loads remote food photos so a single failing URL
/// never breaks the layout or spams the console.
class AppNetworkImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;

  const AppNetworkImage(
    this.url, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      // Spinner while downloading.
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child; // finished loading
        return _placeholder(
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      // Neutral placeholder if the request fails (404 / offline / etc.).
      errorBuilder: (context, error, stackTrace) => _placeholder(
        const Icon(Icons.broken_image_outlined, color: Colors.grey),
      ),
    );
  }

  Widget _placeholder(Widget child) {
    return Container(
      width: width,
      height: height,
      color: const Color(0xffF1F1F1),
      alignment: Alignment.center,
      child: child,
    );
  }
}
