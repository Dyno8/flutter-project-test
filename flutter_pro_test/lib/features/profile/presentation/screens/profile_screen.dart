import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/models/user_profile_model.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_info_card.dart';

/// Main profile screen for users
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load current user profile
    // In a real app, you'd get the UID from the auth state
    context.read<ProfileBloc>().add(const LoadUserProfile(uid: 'current_user_id'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Hồ sơ cá nhân'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
              context.push('/settings');
            },
          ),
        ],
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          } else if (state is ProfileUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Cập nhật hồ sơ thành công'),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProfileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64.sp,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Không thể tải hồ sơ',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    state.message,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProfileBloc>().add(
                        const LoadUserProfile(uid: 'current_user_id'),
                      );
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (state is ProfileLoaded) {
            return _buildProfileContent(context, state.profile);
          }

          return const Center(child: Text('Chưa có dữ liệu hồ sơ'));
        },
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, UserProfileModel profile) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ProfileBloc>().add(
          RefreshProfile(uid: profile.uid),
        );
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            _buildProfileHeader(context, profile),
            SizedBox(height: 24.h),
            _buildProfileInfo(context, profile),
            SizedBox(height: 24.h),
            _buildActionButtons(context, profile),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserProfileModel profile) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ProfileAvatar(
            imageUrl: profile.avatar,
            initials: profile.initials,
            size: 100,
            showEditIcon: true,
            onTap: () {
              // Handle avatar update
              _showAvatarOptions(context, profile.uid);
            },
          ),
          SizedBox(height: 16.h),
          Text(
            profile.displayName,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            profile.role.displayName,
            style: TextStyle(
              fontSize: 16.sp,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: _getCompletionColor(profile.profileCompletionPercentage).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              'Hoàn thành ${profile.profileCompletionPercentage.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 12.sp,
                color: _getCompletionColor(profile.profileCompletionPercentage),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo(BuildContext context, UserProfileModel profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thông tin cá nhân',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        SizedBox(height: 12.h),
        ProfileInfoCard(
          title: 'Email',
          value: profile.email,
          icon: Icons.email_outlined,
          isVerified: profile.isEmailVerified,
          onTap: () {
            // Navigate to edit email
            context.push('/profile/edit-email');
          },
        ),
        ProfileInfoCard(
          title: 'Số điện thoại',
          value: profile.phoneNumber,
          icon: Icons.phone_outlined,
          isVerified: profile.isPhoneVerified,
          onTap: () {
            // Navigate to edit phone
            context.push('/profile/edit-phone');
          },
        ),
        ProfileInfoCard(
          title: 'Tuổi',
          value: profile.ageString,
          icon: Icons.cake_outlined,
          onTap: () {
            // Navigate to edit date of birth
            context.push('/profile/edit-birthday');
          },
        ),
        ProfileInfoCard(
          title: 'Địa chỉ',
          value: profile.fullAddress.isNotEmpty ? profile.fullAddress : null,
          icon: Icons.location_on_outlined,
          onTap: () {
            // Navigate to edit address
            context.push('/profile/edit-address');
          },
        ),
        if (profile.bio != null && profile.bio!.isNotEmpty)
          ProfileInfoCard(
            title: 'Giới thiệu',
            value: profile.bio,
            icon: Icons.info_outlined,
            onTap: () {
              // Navigate to edit bio
              context.push('/profile/edit-bio');
            },
          ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, UserProfileModel profile) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              // Navigate to edit profile
              context.push('/profile/edit');
            },
            icon: const Icon(Icons.edit),
            label: const Text('Chỉnh sửa hồ sơ'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              _showSignOutDialog(context);
            },
            icon: const Icon(Icons.logout),
            label: const Text('Đăng xuất'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getCompletionColor(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 50) return Colors.orange;
    return Colors.red;
  }

  void _showAvatarOptions(BuildContext context, String uid) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Cập nhật ảnh đại diện',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.h),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Chụp ảnh'),
              onTap: () {
                Navigator.pop(context);
                // Handle camera
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Chọn từ thư viện'),
              onTap: () {
                Navigator.pop(context);
                // Handle gallery
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(const SignOutRequested());
            },
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}
