import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../domain/entities/admin_user.dart';
import '../bloc/admin_auth_bloc.dart';

/// Custom app bar for admin screens
class AdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final bool showUserInfo;
  final VoidCallback? onBackPressed;

  const AdminAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.showUserInfo = true,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      shadowColor: AppColors.shadow.withValues(alpha: 0.1),
      surfaceTintColor: Colors.transparent,
      leading: showBackButton
          ? IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: AppColors.textPrimary,
                size: 20.sp,
              ),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            )
          : null,
      title: Row(
        children: [
          Container(
            width: 32.w,
            height: 32.h,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.admin_panel_settings,
              color: Colors.white,
              size: 18.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (showUserInfo)
                  BlocBuilder<AdminAuthBloc, AdminAuthState>(
                    builder: (context, state) {
                      if (state is AdminAuthenticated) {
                        return Text(
                          _getRoleDisplayText(state.admin.role),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (showUserInfo) _buildUserMenu(context),
        if (actions != null) ...actions!,
        SizedBox(width: 8.w),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1.h),
        child: Container(height: 1.h, color: AppColors.border),
      ),
    );
  }

  Widget _buildUserMenu(BuildContext context) {
    return BlocBuilder<AdminAuthBloc, AdminAuthState>(
      builder: (context, state) {
        if (state is AdminAuthenticated) {
          return PopupMenuButton<String>(
            icon: Container(
              width: 36.w,
              height: 36.h,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Icon(Icons.person, color: AppColors.primary, size: 20.sp),
            ),
            offset: Offset(0, 50.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            elevation: 8,
            shadowColor: AppColors.shadow.withValues(alpha: 0.2),
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.admin.displayName,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      state.admin.email,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: _getRoleColor(
                          state.admin.role,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        _getRoleDisplayText(state.admin.role),
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: _getRoleColor(state.admin.role),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 18.sp,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(
                      Icons.settings_outlined,
                      size: 18.sp,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 18.sp, color: AppColors.error),
                    SizedBox(width: 12.w),
                    Text(
                      'Sign Out',
                      style: TextStyle(fontSize: 14.sp, color: AppColors.error),
                    ),
                  ],
                ),
              ),
            ],
            onSelected: (value) => _handleMenuAction(context, value),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'profile':
        // Navigate to admin profile
        break;
      case 'settings':
        // Navigate to admin settings
        break;
      case 'logout':
        _showLogoutDialog(context);
        break;
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Sign Out',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to sign out of the admin dashboard?',
          style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AdminAuthBloc>().add(AdminLogoutRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Sign Out',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _getRoleDisplayText(AdminRole role) {
    switch (role) {
      case AdminRole.superAdmin:
        return 'Super Administrator';
      case AdminRole.admin:
        return 'Administrator';
      case AdminRole.viewer:
        return 'Viewer';
    }
  }

  Color _getRoleColor(AdminRole role) {
    switch (role) {
      case AdminRole.superAdmin:
        return AppColors.error;
      case AdminRole.admin:
        return AppColors.primary;
      case AdminRole.viewer:
        return AppColors.warning;
    }
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 1.h);
}
