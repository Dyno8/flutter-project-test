import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Simple test app to demonstrate payment integration
class PaymentTestApp extends StatelessWidget {
  const PaymentTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Payment Test App',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          home: const PaymentTestHome(),
        );
      },
    );
  }
}

class PaymentTestHome extends StatelessWidget {
  const PaymentTestHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Integration Test'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'CareNow Payment System Test',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 32.h),

            Text(
              'This test app demonstrates the payment integration with:',
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            SizedBox(height: 16.h),

            _buildFeatureItem(context, '✅ Payment Method Selection'),
            _buildFeatureItem(context, '✅ Mock Payment Processing'),
            _buildFeatureItem(context, '✅ Stripe Integration (Mock)'),
            _buildFeatureItem(context, '✅ Payment Status Handling'),
            _buildFeatureItem(context, '✅ Error Handling'),

            SizedBox(height: 32.h),

            ElevatedButton(
              onPressed: () => _testPaymentMethodSelection(context),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Test Payment Method Selection',
                style: TextStyle(fontSize: 16.sp),
              ),
            ),

            SizedBox(height: 16.h),

            ElevatedButton(
              onPressed: () => _testPaymentProcessing(context),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Test Payment Processing',
                style: TextStyle(fontSize: 16.sp),
              ),
            ),

            SizedBox(height: 32.h),

            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Test Scenarios:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '• Mock Payment: Always succeeds after 2 seconds\n'
                    '• Stripe Payment: Mock implementation with 3 second delay\n'
                    '• Cash Payment: Instant success\n'
                    '• Error Handling: Network and validation errors',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: Colors.green[700]),
      ),
    );
  }

  void _testPaymentMethodSelection(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment Method Selection Screen would open here'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _testPaymentProcessing(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment Processing Screen would open here'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

void main() {
  runApp(const PaymentTestApp());
}
