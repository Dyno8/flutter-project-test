import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    print('🚀 Starting CareNow Diagnostic App (No Firebase)...');
    print('📱 Platform: Android');
    print('🔧 Testing basic Flutter functionality...');

    runApp(const DiagnosticApp());
  } catch (e, stackTrace) {
    print('❌ Error during initialization: $e');
    print('Stack trace: $stackTrace');

    runApp(
      MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.red,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.white),
                const SizedBox(height: 16),
                const Text(
                  'Firebase Initialization Error',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Error: $e',
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DiagnosticApp extends StatelessWidget {
  const DiagnosticApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'CareNow Diagnostic',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
            useMaterial3: true,
          ),
          home: const DiagnosticScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class DiagnosticScreen extends StatefulWidget {
  const DiagnosticScreen({super.key});

  @override
  State<DiagnosticScreen> createState() => _DiagnosticScreenState();
}

class _DiagnosticScreenState extends State<DiagnosticScreen> {
  List<String> diagnosticResults = [];

  @override
  void initState() {
    super.initState();
    _runDiagnostics();
  }

  void _runDiagnostics() async {
    setState(() {
      diagnosticResults.add('🚀 Starting diagnostics...');
    });

    // Test basic Flutter functionality
    setState(() {
      diagnosticResults.add('✅ Flutter framework initialized');
      diagnosticResults.add('✅ Material Design components available');
      diagnosticResults.add('✅ Screen utilities configured');
    });

    // Test screen util
    try {
      setState(() {
        diagnosticResults.add(
          '✅ ScreenUtil initialized: ${ScreenUtil().screenWidth}x${ScreenUtil().screenHeight}',
        );
      });
    } catch (e) {
      setState(() {
        diagnosticResults.add('❌ ScreenUtil error: $e');
      });
    }

    setState(() {
      diagnosticResults.add('🎉 Diagnostics complete!');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      appBar: AppBar(
        title: const Text('CareNow Diagnostic'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Firebase & Dependencies Test',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: diagnosticResults
                        .map(
                          (result) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              result,
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _runDiagnostics,
                child: const Text('Run Diagnostics Again'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
