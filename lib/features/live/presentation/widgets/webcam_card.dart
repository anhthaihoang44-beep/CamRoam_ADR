import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/live_badge.dart';
import '../../../../core/widgets/hot_badge.dart';
import '../../data/models/webcam_model.dart';

class WebcamCard extends StatelessWidget {
  final WebcamModel webcam;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final double width;
  final double height;

  const WebcamCard({
    super.key,
    required this.webcam,
    required this.onTap,
    this.isFavorite = false,
    required this.onToggleFavorite,
    this.width = 220,
    this.height = 190,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.only(right: 14),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderSubtle, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Thumbnail with Badges
              Expanded(
                flex: 11,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: webcam.thumbnailUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.surfaceLight,
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.cyan,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.surfaceLight,
                        child: const Center(
                          child: Icon(Icons.videocam_off_rounded,
                              color: AppColors.textSecondary),
                        ),
                      ),
                    ),

                    // Top Badges
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const LiveBadge(compact: true),
                          if (webcam.isHot) ...[
                            const SizedBox(width: 5),
                            const HotBadge(fontSize: 10),
                          ],
                        ],
                      ),
                    ),

                    // Favorite Button
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Material(
                        color: Colors.black.withOpacity(0.4),
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: onToggleFavorite,
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? AppColors.liveRed : Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Gradient Scrim at bottom of image
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 30,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              AppColors.surfaceCard.withOpacity(0.9),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Info Section
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      webcam.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 1,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: AppColors.cyan,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            '${webcam.city}, ${webcam.country}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11.5,
                              overflow: TextOverflow.ellipsis,
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

