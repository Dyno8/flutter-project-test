import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddressInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(String address, double latitude, double longitude) onAddressSelected;

  const AddressInputWidget({
    super.key,
    required this.controller,
    required this.onAddressSelected,
  });

  @override
  State<AddressInputWidget> createState() => _AddressInputWidgetState();
}

class _AddressInputWidgetState extends State<AddressInputWidget> {
  bool _isUsingCurrentLocation = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Address Input Field
        TextField(
          controller: widget.controller,
          decoration: InputDecoration(
            hintText: 'Nhập địa chỉ dịch vụ',
            prefixIcon: const Icon(Icons.location_on),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            contentPadding: EdgeInsets.all(16.w),
          ),
          onChanged: (value) {
            if (value.isNotEmpty) {
              // For now, use mock coordinates
              // In a real app, you'd integrate with Google Places API or similar
              widget.onAddressSelected(
                value,
                10.762622, // Mock latitude (Ho Chi Minh City)
                106.660172, // Mock longitude
              );
            }
          },
        ),
        SizedBox(height: 12.h),

        // Use Current Location Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isUsingCurrentLocation ? null : _useCurrentLocation,
            icon: _isUsingCurrentLocation
                ? SizedBox(
                    width: 16.w,
                    height: 16.h,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location),
            label: Text(
              _isUsingCurrentLocation 
                  ? 'Đang lấy vị trí...' 
                  : 'Sử dụng vị trí hiện tại',
            ),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
        SizedBox(height: 8.h),

        // Address Suggestions (Mock)
        if (widget.controller.text.isNotEmpty) ...[
          Text(
            'Gợi ý địa chỉ:',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8.h),
          _buildAddressSuggestion(
            '123 Nguyễn Văn Cừ, Quận 5, TP.HCM',
            10.762622,
            106.660172,
          ),
          _buildAddressSuggestion(
            '456 Lê Văn Sỹ, Quận 3, TP.HCM',
            10.786785,
            106.691742,
          ),
        ],
      ],
    );
  }

  Widget _buildAddressSuggestion(String address, double lat, double lng) {
    return InkWell(
      onTap: () {
        widget.controller.text = address;
        widget.onAddressSelected(address, lat, lng);
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.w),
        margin: EdgeInsets.only(bottom: 8.h),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 16.r,
              color: Colors.grey[600],
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                address,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _useCurrentLocation() async {
    setState(() {
      _isUsingCurrentLocation = true;
    });

    // Mock getting current location
    // In a real app, you'd use location services
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isUsingCurrentLocation = false;
      });

      const mockAddress = 'Vị trí hiện tại của bạn';
      const mockLat = 10.762622;
      const mockLng = 106.660172;

      widget.controller.text = mockAddress;
      widget.onAddressSelected(mockAddress, mockLat, mockLng);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã lấy vị trí hiện tại'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
