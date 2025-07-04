import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/models/user_profile_model.dart';
import '../../../auth/presentation/widgets/auth_text_field.dart';
import '../../../auth/presentation/widgets/auth_button.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

/// Screen for editing user profile
class EditProfileScreen extends StatefulWidget {
  final UserProfileModel profile;

  const EditProfileScreen({
    super.key,
    required this.profile,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _bioController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _districtController;

  String? _selectedGender;
  DateTime? _selectedDateOfBirth;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.displayName);
    _phoneController = TextEditingController(text: widget.profile.phoneNumber ?? '');
    _bioController = TextEditingController(text: widget.profile.bio ?? '');
    _addressController = TextEditingController(text: widget.profile.address ?? '');
    _cityController = TextEditingController(text: widget.profile.city ?? '');
    _districtController = TextEditingController(text: widget.profile.district ?? '');
    _selectedGender = widget.profile.gender;
    _selectedDateOfBirth = widget.profile.dateOfBirth;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Chỉnh sửa hồ sơ'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocListener<ProfileBloc, ProfileState>(
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
            context.pop();
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBasicInfo(),
                SizedBox(height: 24.h),
                _buildPersonalInfo(),
                SizedBox(height: 24.h),
                _buildLocationInfo(),
                SizedBox(height: 32.h),
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thông tin cơ bản',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        SizedBox(height: 16.h),
        AuthTextField(
          label: 'Họ và tên',
          hint: 'Nhập họ và tên của bạn',
          controller: _nameController,
          prefixIcon: Icon(
            Icons.person_outline,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập họ và tên';
            }
            if (value.trim().length < 2) {
              return 'Họ và tên phải có ít nhất 2 ký tự';
            }
            return null;
          },
        ),
        SizedBox(height: 16.h),
        AuthTextField(
          label: 'Số điện thoại',
          hint: 'Nhập số điện thoại',
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          prefixIcon: Icon(
            Icons.phone_outlined,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              if (!RegExp(r'^(\+84|84|0)(3|5|7|8|9)([0-9]{8})$').hasMatch(value)) {
                return 'Số điện thoại không hợp lệ';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPersonalInfo() {
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
        SizedBox(height: 16.h),
        _buildGenderSelector(),
        SizedBox(height: 16.h),
        _buildDateOfBirthSelector(),
        SizedBox(height: 16.h),
        AuthTextField(
          label: 'Giới thiệu',
          hint: 'Viết vài dòng về bản thân',
          controller: _bioController,
          maxLines: 3,
          prefixIcon: Icon(
            Icons.info_outline,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          validator: (value) {
            if (value != null && value.length > 500) {
              return 'Giới thiệu không được quá 500 ký tự';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLocationInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thông tin địa chỉ',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        SizedBox(height: 16.h),
        AuthTextField(
          label: 'Địa chỉ',
          hint: 'Nhập địa chỉ cụ thể',
          controller: _addressController,
          prefixIcon: Icon(
            Icons.home_outlined,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: AuthTextField(
                label: 'Quận/Huyện',
                hint: 'Chọn quận/huyện',
                controller: _districtController,
                prefixIcon: Icon(
                  Icons.location_city_outlined,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: AuthTextField(
                label: 'Tỉnh/Thành phố',
                hint: 'Chọn tỉnh/thành phố',
                controller: _cityController,
                prefixIcon: Icon(
                  Icons.location_on_outlined,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Giới tính',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildGenderOption('Nam', 'male'),
              ),
              Expanded(
                child: _buildGenderOption('Nữ', 'female'),
              ),
              Expanded(
                child: _buildGenderOption('Khác', 'other'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGenderOption(String label, String value) {
    final isSelected = _selectedGender == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = value),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildDateOfBirthSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ngày sinh',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: _selectDateOfBirth,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.cake_outlined,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                SizedBox(width: 12.w),
                Text(
                  _selectedDateOfBirth != null
                      ? '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}'
                      : 'Chọn ngày sinh',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: _selectedDateOfBirth != null
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        return AuthButton(
          text: 'Lưu thay đổi',
          isLoading: state is ProfileOperationInProgress,
          onPressed: _saveProfile,
        );
      },
    );
  }

  void _selectDateOfBirth() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 100)),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 16)),
    );

    if (date != null) {
      setState(() => _selectedDateOfBirth = date);
    }
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) return;

    final updatedProfile = widget.profile.copyWith(
      displayName: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
      gender: _selectedGender,
      dateOfBirth: _selectedDateOfBirth,
      bio: _bioController.text.trim().isNotEmpty ? _bioController.text.trim() : null,
      address: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
      city: _cityController.text.trim().isNotEmpty ? _cityController.text.trim() : null,
      district: _districtController.text.trim().isNotEmpty ? _districtController.text.trim() : null,
      updatedAt: DateTime.now(),
    );

    context.read<ProfileBloc>().add(UpdateUserProfile(profile: updatedProfile));
  }
}
