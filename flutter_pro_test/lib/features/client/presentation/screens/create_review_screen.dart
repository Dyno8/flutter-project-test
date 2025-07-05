import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../booking/domain/entities/booking.dart';
import '../../domain/entities/review.dart';
import '../bloc/review_bloc.dart';
import '../bloc/review_event.dart';
import '../bloc/review_state.dart';
import '../widgets/rating_selector.dart';
import '../widgets/review_tags_selector.dart';

/// Screen for creating a review for a completed booking
class CreateReviewScreen extends StatefulWidget {
  final Booking booking;

  const CreateReviewScreen({
    super.key,
    required this.booking,
  });

  @override
  State<CreateReviewScreen> createState() => _CreateReviewScreenState();
}

class _CreateReviewScreenState extends State<CreateReviewScreen> {
  late ReviewBloc _reviewBloc;
  final TextEditingController _commentController = TextEditingController();
  
  int _rating = 0;
  List<String> _selectedTags = [];
  bool _isRecommended = true;

  @override
  void initState() {
    super.initState();
    _reviewBloc = di.sl<ReviewBloc>();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _reviewBloc,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: const Text('Đánh giá dịch vụ'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          elevation: 0,
        ),
        body: BlocConsumer<ReviewBloc, ReviewState>(
          listener: (context, state) {
            if (state is ReviewError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is ReviewCreated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đánh giá đã được gửi thành công!'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context, true);
            }
          },
          builder: (context, state) {
            return _buildBody(context, state);
          },
        ),
        bottomNavigationBar: _buildBottomBar(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ReviewState state) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Booking info header
          _buildBookingHeader(context),
          
          SizedBox(height: 24.h),
          
          // Rating section
          _buildSectionTitle(context, 'Đánh giá chất lượng dịch vụ'),
          SizedBox(height: 12.h),
          RatingSelector(
            rating: _rating,
            onRatingChanged: (rating) {
              setState(() {
                _rating = rating;
              });
            },
          ),
          
          SizedBox(height: 24.h),
          
          // Tags section
          _buildSectionTitle(context, 'Đánh giá chi tiết'),
          SizedBox(height: 12.h),
          ReviewTagsSelector(
            selectedTags: _selectedTags,
            onTagsChanged: (tags) {
              setState(() {
                _selectedTags = tags;
              });
            },
          ),
          
          SizedBox(height: 24.h),
          
          // Comment section
          _buildSectionTitle(context, 'Nhận xét (tùy chọn)'),
          SizedBox(height: 12.h),
          _buildCommentField(context),
          
          SizedBox(height: 24.h),
          
          // Recommendation section
          _buildRecommendationSection(context),
          
          SizedBox(height: 100.h), // Space for bottom bar
        ],
      ),
    );
  }

  Widget _buildBookingHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.medical_services,
                color: Theme.of(context).colorScheme.primary,
                size: 24.r,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  widget.booking.serviceName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'Hoàn thành vào ${_formatDate(widget.booking.scheduledDate)}',
            style: TextStyle(
              fontSize: 12.sp,
              color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildCommentField(BuildContext context) {
    return TextField(
      controller: _commentController,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: 'Chia sẻ trải nghiệm của bạn về dịch vụ...',
        hintStyle: TextStyle(
          color: Colors.grey[500],
          fontSize: 14.sp,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        contentPadding: EdgeInsets.all(16.w),
      ),
      style: TextStyle(
        fontSize: 14.sp,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildRecommendationSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bạn có muốn giới thiệu dịch vụ này không?',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildRecommendationOption(
                  context,
                  'Có, tôi giới thiệu',
                  Icons.thumb_up,
                  true,
                  _isRecommended,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildRecommendationOption(
                  context,
                  'Không giới thiệu',
                  Icons.thumb_down,
                  false,
                  !_isRecommended,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationOption(
    BuildContext context,
    String label,
    IconData icon,
    bool value,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isRecommended = value;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16.r,
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurface,
            ),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final canSubmit = _rating > 0;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: canSubmit ? _submitReview : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: Text(
            'Gửi đánh giá',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _submitReview() {
    final reviewRequest = ReviewRequest(
      bookingId: widget.booking.id,
      userId: widget.booking.userId,
      partnerId: widget.booking.partnerId,
      serviceId: widget.booking.serviceId,
      rating: _rating,
      comment: _commentController.text.trim().isEmpty 
          ? null 
          : _commentController.text.trim(),
      tags: _selectedTags,
      isRecommended: _isRecommended,
    );

    _reviewBloc.add(CreateReviewEvent(reviewRequest));
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
