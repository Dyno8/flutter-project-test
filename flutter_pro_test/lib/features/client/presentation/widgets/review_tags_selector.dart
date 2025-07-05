import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Widget for selecting review tags
class ReviewTagsSelector extends StatelessWidget {
  final List<String> selectedTags;
  final ValueChanged<List<String>> onTagsChanged;

  const ReviewTagsSelector({
    super.key,
    required this.selectedTags,
    required this.onTagsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Positive tags
        _buildTagSection(
          context,
          'Điểm tốt',
          _positiveTags,
          Colors.green,
          Icons.thumb_up,
        ),
        
        SizedBox(height: 16.h),
        
        // Improvement tags
        _buildTagSection(
          context,
          'Cần cải thiện',
          _improvementTags,
          Colors.orange,
          Icons.construction,
        ),
      ],
    );
  }

  Widget _buildTagSection(
    BuildContext context,
    String title,
    List<ReviewTag> tags,
    Color color,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 16.r,
            ),
            SizedBox(width: 8.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        
        SizedBox(height: 8.h),
        
        // Tags
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: tags.map((tag) => _buildTagChip(context, tag, color)).toList(),
        ),
      ],
    );
  }

  Widget _buildTagChip(BuildContext context, ReviewTag tag, Color sectionColor) {
    final isSelected = selectedTags.contains(tag.value);

    return GestureDetector(
      onTap: () {
        final newTags = List<String>.from(selectedTags);
        if (isSelected) {
          newTags.remove(tag.value);
        } else {
          newTags.add(tag.value);
        }
        onTagsChanged(newTags);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? sectionColor
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected
                ? sectionColor
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Text(
          tag.label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  // Predefined positive tags
  static final List<ReviewTag> _positiveTags = [
    ReviewTag('punctual', 'Đúng giờ'),
    ReviewTag('professional', 'Chuyên nghiệp'),
    ReviewTag('friendly', 'Thân thiện'),
    ReviewTag('careful', 'Tỉ mỉ'),
    ReviewTag('experienced', 'Có kinh nghiệm'),
    ReviewTag('clean', 'Sạch sẽ'),
    ReviewTag('patient', 'Kiên nhẫn'),
    ReviewTag('helpful', 'Hỗ trợ tốt'),
    ReviewTag('reliable', 'Đáng tin cậy'),
    ReviewTag('skilled', 'Có kỹ năng'),
  ];

  // Predefined improvement tags
  static final List<ReviewTag> _improvementTags = [
    ReviewTag('late', 'Đến muộn'),
    ReviewTag('communication', 'Giao tiếp'),
    ReviewTag('attitude', 'Thái độ'),
    ReviewTag('quality', 'Chất lượng'),
    ReviewTag('cleanliness', 'Vệ sinh'),
    ReviewTag('equipment', 'Dụng cụ'),
    ReviewTag('time_management', 'Quản lý thời gian'),
    ReviewTag('follow_instructions', 'Làm theo yêu cầu'),
  ];
}

/// Data class for review tags
class ReviewTag {
  final String value;
  final String label;

  const ReviewTag(this.value, this.label);
}

/// Widget for displaying review tags (read-only)
class ReviewTagsDisplay extends StatelessWidget {
  final List<String> tags;
  final Color? color;

  const ReviewTagsDisplay({
    super.key,
    required this.tags,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) return const SizedBox.shrink();

    final displayColor = color ?? Theme.of(context).colorScheme.primary;

    return Wrap(
      spacing: 6.w,
      runSpacing: 6.h,
      children: tags.map((tag) {
        final tagInfo = _getTagInfo(tag);
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: displayColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            tagInfo.label,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: displayColor,
            ),
          ),
        );
      }).toList(),
    );
  }

  ReviewTag _getTagInfo(String value) {
    // Combine all tags for lookup
    final allTags = [
      ...ReviewTagsSelector._positiveTags,
      ...ReviewTagsSelector._improvementTags,
    ];

    return allTags.firstWhere(
      (tag) => tag.value == value,
      orElse: () => ReviewTag(value, value),
    );
  }
}
