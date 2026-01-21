import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/attachment_entity.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_client.dart';

/// Widget to display attachments in a grid layout
class AttachmentGalleryWidget extends StatelessWidget {
  const AttachmentGalleryWidget({
    super.key,
    required this.attachments,
    this.onImageTap,
    this.showMetadata = true,
    this.columns = 4,
  });

  final List<AttachmentEntity> attachments;
  final void Function(AttachmentEntity attachment, int index)? onImageTap;
  final bool showMetadata;
  final int columns;

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) {
      return const SizedBox.shrink();
    }

    // Filter to only show images
    final imageAttachments =
        attachments.where((att) => att.isImage && !att.isDeleted).toList();

    if (imageAttachments.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Responsive column count based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final responsiveColumns = screenWidth > 768
        ? (columns + 1) // Desktop: add one more column
        : columns; // Mobile: use default

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showMetadata)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              '${imageAttachments.length} ${imageAttachments.length == 1 ? 'image' : 'images'}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: responsiveColumns,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            childAspectRatio: 1.0,
          ),
          itemCount: imageAttachments.length,
          itemBuilder: (context, index) {
            final attachment = imageAttachments[index];
            // Extract ticketId from attachment or pass it from parent
            // For now, we'll need to get it from the attachment's ticketId
            return _AttachmentThumbnail(
              attachment: attachment,
              ticketId: attachment.ticketId,
              onTap: () => onImageTap?.call(attachment, index),
            );
          },
        ),
      ],
    );
  }
}

class _AttachmentThumbnail extends StatefulWidget {
  const _AttachmentThumbnail({
    required this.attachment,
    required this.ticketId,
    this.onTap,
  });

  final AttachmentEntity attachment;
  final String ticketId;
  final VoidCallback? onTap;

  @override
  State<_AttachmentThumbnail> createState() => _AttachmentThumbnailState();
}

class _AttachmentThumbnailState extends State<_AttachmentThumbnail> {
  String? _presignedUrl;
  bool _isLoadingPresignedUrl = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPresignedUrlIfNeeded();
  }

  Future<void> _loadPresignedUrlIfNeeded() async {
    // Use storagePath to get presigned URL (new generic endpoint pattern)
    // This follows the same pattern as upload: generic endpoint for all entity types
    final storagePath = widget.attachment.storagePath;
    if (storagePath.isEmpty) {
      return;
    }

    // Always get presigned URL for S3 files (private buckets require it)
    setState(() {
      _isLoadingPresignedUrl = true;
      _error = null;
    });

    try {
      final apiClient = getIt<ApiClient>();
      // Use new generic endpoint: GET /uploads/presigned-url?storagePath=...
      final presignedUrl = await apiClient.generatePresignedDownloadUrlGeneric(
        storagePath: storagePath,
        expiresIn: 3600, // 1 hour
      );

      if (mounted) {
        setState(() {
          _presignedUrl = presignedUrl;
          _isLoadingPresignedUrl = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Failed to get presigned URL: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoadingPresignedUrl = false;
        });
      }
    }
  }

  String get _imageUrl {
    // Always use presigned URL if available (for private S3 buckets)
    // This is the preferred method for S3 files
    if (_presignedUrl != null && _presignedUrl!.isNotEmpty) {
      debugPrint('🖼️ Using presigned URL: $_presignedUrl');
      return _presignedUrl!;
    }

    // If presigned URL is not loaded yet, use storagePath to construct legacy URL
    // This will work via the backend redirect endpoint until presigned URL loads
    final storagePath = widget.attachment.storagePath;
    if (storagePath.isNotEmpty) {
      // Use backend redirect endpoint: /uploads/{storagePath}
      // Backend will redirect to S3 presigned URL
      final redirectUrl =
          '${AppConfig.apiBaseUrl.replaceAll('/api/v1', '')}/uploads/$storagePath';
      debugPrint('🖼️ Using redirect URL (will get presigned URL): $redirectUrl');
      return redirectUrl;
    }

    // Last resort: use storageUrl if available (shouldn't happen with S3)
    final storageUrl = widget.attachment.storageUrl;
    if (storageUrl != null && storageUrl.isNotEmpty) {
      debugPrint('🖼️ Using storageUrl (fallback): $storageUrl');
      return storageUrl;
    }

    // Should never reach here, but return empty string as fallback
    debugPrint('⚠️ No valid image URL found for attachment');
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.05), // Use theme color for dark mode
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Show loading while fetching presigned URL
          if (_isLoadingPresignedUrl)
            Container(
              color: colorScheme.surfaceContainerHighest,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.primary,
                ),
              ),
            )
          // Show error if presigned URL failed
          else if (_error != null)
            Container(
              color: colorScheme.surfaceContainerHighest,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: colorScheme.error,
                    size: 32,
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'Load failed',
                      style: TextStyle(
                        fontSize: 10,
                        color: colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )
          // Show image
          else
            CachedNetworkImage(
              imageUrl: _imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: colorScheme.surfaceContainerHighest,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              errorWidget: (context, url, error) {
                // Log error for debugging
                debugPrint('❌ Image load error for: $url');
                debugPrint('   Error: $error');
                debugPrint('   Attachment: ${widget.attachment.originalName}');
                debugPrint('   Storage URL: ${widget.attachment.storageUrl}');
                debugPrint('   Storage Path: ${widget.attachment.storagePath}');
                debugPrint('   Presigned URL: $_presignedUrl');
                return Container(
                  color: colorScheme.surfaceContainerHighest,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.broken_image_outlined,
                        color: colorScheme.onSurfaceVariant,
                        size: 32,
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'Failed to load',
                          style: TextStyle(
                            fontSize: 10,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          // Overlay on hover/tap
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0),
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
}

/// Full-screen image preview dialog with zoom and navigation
class ImagePreviewDialog extends StatefulWidget {
  const ImagePreviewDialog({
    super.key,
    required this.attachments,
    required this.initialIndex,
  });

  final List<AttachmentEntity> attachments;
  final int initialIndex;

  @override
  State<ImagePreviewDialog> createState() => _ImagePreviewDialogState();
}

class _ImagePreviewDialogState extends State<ImagePreviewDialog> {
  late PageController _pageController;
  late int _currentIndex;
  final TransformationController _transformationController =
      TransformationController();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  Future<String> _getImageUrl(AttachmentEntity attachment) async {
    // For S3 files, fetch presigned URL using new generic endpoint
    final storagePath = attachment.storagePath;
    if (storagePath.isNotEmpty) {
      try {
        final apiClient = getIt<ApiClient>();
        // Use new generic endpoint: GET /uploads/presigned-url?storagePath=...
        final presignedUrl = await apiClient.generatePresignedDownloadUrlGeneric(
          storagePath: storagePath,
          expiresIn: 3600,
        );
        debugPrint('🖼️ Preview using presigned URL: $presignedUrl');
        return presignedUrl;
      } catch (e) {
        debugPrint('❌ Failed to get presigned URL for preview: $e');
        // Fall through to use direct URL
      }
    }

    // Fallback: use backend redirect endpoint if presigned URL fetch failed
    // Backend will redirect to S3 presigned URL
    if (storagePath.isNotEmpty) {
      final redirectUrl =
          '${AppConfig.apiBaseUrl.replaceAll('/api/v1', '')}/uploads/$storagePath';
      debugPrint('🖼️ Preview using redirect URL: $redirectUrl');
      return redirectUrl;
    }

    // Last resort: use storageUrl if available (shouldn't happen with S3)
    final storageUrl = attachment.storageUrl;
    if (storageUrl != null && storageUrl.isNotEmpty) {
      debugPrint('🖼️ Preview using storageUrl (fallback): $storageUrl');
      return storageUrl;
    }

    // Should never reach here
    debugPrint('⚠️ No valid image URL found for preview');
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final currentAttachment = widget.attachments[_currentIndex];

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          // Image viewer with zoom
          PageView.builder(
            controller: _pageController,
            itemCount: widget.attachments.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
                _resetZoom();
              });
            },
            itemBuilder: (context, index) {
              final attachment = widget.attachments[index];
              return FutureBuilder<String>(
                future: _getImageUrl(attachment),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      color: Colors.black87,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                    );
                  }

                  if (snapshot.hasError || !snapshot.hasData) {
                    return Container(
                      color: Colors.black87,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: Colors.white70,
                          size: 48,
                        ),
                      ),
                    );
                  }

                  return InteractiveViewer(
                    transformationController: _transformationController,
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Center(
                      child: CachedNetworkImage(
                        imageUrl: snapshot.data!,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => Container(
                          color: Colors.black87,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.black87,
                          child: const Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              color: Colors.white70,
                              size: 48,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),

          // Close button
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),

          // Image counter and metadata
          if (widget.attachments.length > 1)
            Positioned(
              top: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / ${widget.attachments.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),

          // Metadata at bottom
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentAttachment.originalName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        currentAttachment.fileSizeFormatted,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('MMM dd, yyyy • HH:mm')
                            .format(currentAttachment.createdAt),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Navigation arrows
          if (widget.attachments.length > 1) ...[
            if (_currentIndex > 0)
              Positioned(
                left: 20,
                top: 0,
                bottom: 0,
                child: Center(
                  child: IconButton(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            if (_currentIndex < widget.attachments.length - 1)
              Positioned(
                right: 20,
                top: 0,
                bottom: 0,
                child: Center(
                  child: IconButton(
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
