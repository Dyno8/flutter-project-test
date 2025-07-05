import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Simple demo to show payment integration is working
class SimplePaymentDemo extends StatelessWidget {
  const SimplePaymentDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Payment Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          home: const PaymentDemoHome(),
        );
      },
    );
  }
}

class PaymentDemoHome extends StatefulWidget {
  const PaymentDemoHome({super.key});

  @override
  State<PaymentDemoHome> createState() => _PaymentDemoHomeState();
}

class _PaymentDemoHomeState extends State<PaymentDemoHome> {
  String? selectedPaymentMethod;
  bool isProcessing = false;
  String? paymentResult;

  final List<Map<String, dynamic>> paymentMethods = [
    {
      'id': 'mock',
      'name': 'Mock Payment',
      'description': 'Thanh toán giả lập cho thử nghiệm',
      'icon': Icons.code,
      'color': Colors.purple,
    },
    {
      'id': 'stripe',
      'name': 'Stripe Payment',
      'description': 'Thanh toán bằng thẻ tín dụng/ghi nợ',
      'icon': Icons.credit_card,
      'color': Colors.blue,
    },
    {
      'id': 'cash',
      'name': 'Cash Payment',
      'description': 'Thanh toán tiền mặt khi hoàn thành',
      'icon': Icons.money,
      'color': Colors.green,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Integration Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'CareNow Payment System',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 32.h),
            
            // Payment Summary
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chi tiết thanh toán',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    SizedBox(height: 16.h),
                    _buildSummaryRow('Dịch vụ', 'Chăm sóc người cao tuổi'),
                    _buildSummaryRow('Thời gian', '3.0 giờ'),
                    _buildSummaryRow('Giá cơ bản', '150.000₫'),
                    const Divider(),
                    _buildSummaryRow('Tổng cộng', '150.000₫', isTotal: true),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 24.h),
            
            Text(
              'Chọn phương thức thanh toán',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            
            SizedBox(height: 16.h),
            
            // Payment Methods
            ...paymentMethods.map((method) => _buildPaymentMethodCard(method)),
            
            SizedBox(height: 32.h),
            
            // Process Payment Button
            ElevatedButton(
              onPressed: selectedPaymentMethod != null && !isProcessing
                  ? _processPayment
                  : null,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: isProcessing
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: const CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12.w),
                        const Text('Đang xử lý...'),
                      ],
                    )
                  : const Text('Xử lý thanh toán'),
            ),
            
            // Payment Result
            if (paymentResult != null) ...[
              SizedBox(height: 24.h),
              Card(
                color: paymentResult!.contains('thành công')
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: [
                      Icon(
                        paymentResult!.contains('thành công')
                            ? Icons.check_circle
                            : Icons.error,
                        color: paymentResult!.contains('thành công')
                            ? Colors.green
                            : Colors.red,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          paymentResult!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    )
                : Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: isTotal
                ? Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    )
                : Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(Map<String, dynamic> method) {
    final isSelected = selectedPaymentMethod == method['id'];
    
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedPaymentMethod = method['id'];
            paymentResult = null; // Clear previous result
          });
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: (method['color'] as Color).withAlpha(25),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  method['icon'] as IconData,
                  color: method['color'] as Color,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method['name'] as String,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      method['description'] as String,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24.sp,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _processPayment() async {
    setState(() {
      isProcessing = true;
      paymentResult = null;
    });

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      isProcessing = false;
      
      // Simulate different payment results
      switch (selectedPaymentMethod) {
        case 'mock':
          paymentResult = 'Thanh toán Mock thành công! Mã giao dịch: MOCK_${DateTime.now().millisecondsSinceEpoch}';
          break;
        case 'stripe':
          paymentResult = 'Thanh toán Stripe thành công! Mã giao dịch: pi_${DateTime.now().millisecondsSinceEpoch}';
          break;
        case 'cash':
          paymentResult = 'Đặt lịch thành công! Thanh toán tiền mặt khi hoàn thành dịch vụ.';
          break;
        default:
          paymentResult = 'Thanh toán thất bại! Vui lòng thử lại.';
      }
    });
  }
}

void main() {
  runApp(const SimplePaymentDemo());
}
