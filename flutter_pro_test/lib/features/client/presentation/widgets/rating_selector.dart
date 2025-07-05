import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Widget for selecting a rating (1-5 stars)
class RatingSelector extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onRatingChanged;
  final double starSize;
  final bool enabled;

  const RatingSelector({
    super.key,
    required this.rating,
    required this.onRatingChanged,
    this.starSize = 40.0,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Star rating
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final starIndex = index + 1;
            return GestureDetector(
              onTap: enabled ? () => onRatingChanged(starIndex) : null,
              child: Container(
                padding: EdgeInsets.all(4.w),
                child: Icon(
                  starIndex <= rating ? Icons.star : Icons.star_border,
                  size: starSize.r,
                  color: starIndex <= rating
                      ? _getStarColor(rating)
                      : Colors.grey[400],
                ),
              ),
            );
          }),
        ),
        
        SizedBox(height: 12.h),
        
        // Rating description
        if (rating > 0) _buildRatingDescription(context),
      ],
    );
  }

  Widget _buildRatingDescription(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: _getStarColor(rating).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        _getRatingDescription(rating),
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: _getStarColor(rating),
        ),
      ),
    );
  }

  Color _getStarColor(int rating) {
    switch (rating) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.amber;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getRatingDescription(int rating) {
    switch (rating) {
      case 1:
        return 'Rất không hài lòng';
      case 2:
        return 'Không hài lòng';
      case 3:
        return 'Bình thường';
      case 4:
        return 'Hài lòng';
      case 5:
        return 'Rất hài lòng';
      default:
        return '';
    }
  }
}

/// Widget for displaying a read-only rating
class RatingDisplay extends StatelessWidget {
  final double rating;
  final int totalReviews;
  final double starSize;
  final bool showText;

  const RatingDisplay({
    super.key,
    required this.rating,
    this.totalReviews = 0,
    this.starSize = 16.0,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Stars
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            final starIndex = index + 1;
            return Icon(
              starIndex <= rating.floor()
                  ? Icons.star
                  : starIndex <= rating
                      ? Icons.star_half
                      : Icons.star_border,
              size: starSize.r,
              color: Colors.amber,
            );
          }),
        ),
        
        if (showText) ...[
          SizedBox(width: 4.w),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: (starSize * 0.8).sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          if (totalReviews > 0) ...[
            Text(
              ' (${totalReviews})',
              style: TextStyle(
                fontSize: (starSize * 0.7).sp,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ],
      ],
    );
  }
}
