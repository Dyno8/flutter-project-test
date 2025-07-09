import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'shared/services/firebase_service.dart';
import 'core/di/injection_container.dart' as di;

void main() async {
  runApp(const StepByStepApp());
}

class StepByStepApp extends StatelessWidget {
  const StepByStepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'CareNow Step-by-Step Test',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
            useMaterial3: true,
          ),
          home: const StepByStepScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class StepByStepScreen extends StatefulWidget {
  const StepByStepScreen({super.key});

  @override
  State<StepByStepScreen> createState() => _StepByStepScreenState();
}

class _StepByStepScreenState extends State<StepByStepScreen> {
  List<String> logs = [];
  bool isRunning = false;
  String currentStep = '';

  void addLog(String message) {
    setState(() {
      logs.add(message);
    });
    print(message); // Also print to console
  }

  Future<void> runStepByStepInitialization() async {
    setState(() {
      isRunning = true;
      logs.clear();
      currentStep = 'Starting...';
    });

    try {
      // Step 1: Flutter binding
      addLog('🚀 Step 1: Initializing Flutter binding...');
      WidgetsFlutterBinding.ensureInitialized();
      addLog('✅ Flutter binding initialized');

      // Step 2: Firebase initialization
      setState(() => currentStep = 'Firebase initialization');
      addLog('🔥 Step 2: Initializing Firebase...');
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      addLog('✅ Firebase initialized successfully');

      final app = Firebase.app();
      addLog('📱 Firebase app name: ${app.name}');
      addLog('🏗️ Firebase project: ${app.options.projectId}');

      // Step 3: Firebase services
      setState(() => currentStep = 'Firebase services');
      addLog('🔧 Step 3: Initializing Firebase services...');
      await FirebaseService().initialize();
      addLog('✅ Firebase services initialized');

      // Step 4: Dependency injection
      setState(() => currentStep = 'Dependency injection');
      addLog('💉 Step 4: Initializing dependency injection...');
      await di.init();
      addLog('✅ Dependency injection initialized');

      // Step 5: Test some key services
      setState(() => currentStep = 'Testing services');
      addLog('🧪 Step 5: Testing key services...');

      try {
        // Test if we can get Firebase instances
        final firebaseAuth = di.sl.get<FirebaseAuth>();
        addLog('✅ FirebaseAuth service: ${firebaseAuth.app.name}');

        final firestore = di.sl.get<FirebaseFirestore>();
        addLog('✅ Firestore service: ${firestore.app.name}');

        addLog('✅ Service locator is working correctly');
      } catch (e) {
        addLog('⚠️ Service locator test: $e');
      }

      addLog('🎉 All steps completed successfully!');
      setState(() => currentStep = 'Completed');
    } catch (e, stackTrace) {
      addLog('❌ Error in step "$currentStep": $e');
      addLog('📋 Stack trace: ${stackTrace.toString().substring(0, 200)}...');
      setState(() => currentStep = 'Failed');
    } finally {
      setState(() => isRunning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      appBar: AppBar(
        title: const Text('Step-by-Step Initialization Test'),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Step: $currentStep',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            if (isRunning)
              const LinearProgressIndicator(
                backgroundColor: Colors.white30,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
                    children: logs
                        .map(
                          (log) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              log,
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'monospace',
                                fontSize: 12,
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
                onPressed: isRunning ? null : runStepByStepInitialization,
                child: Text(
                  isRunning ? 'Running...' : 'Start Step-by-Step Test',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
