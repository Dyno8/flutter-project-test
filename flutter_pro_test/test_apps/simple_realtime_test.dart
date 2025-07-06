import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';

// Import only the essential components for real-time booking
import 'package:flutter_pro_test/shared/services/realtime_booking_service.dart';
import 'package:flutter_pro_test/shared/services/firebase_service.dart';
import 'package:flutter_pro_test/shared/services/notification_service.dart';
import 'package:flutter_pro_test/features/booking/presentation/bloc/realtime_booking_bloc.dart';
import 'package:flutter_pro_test/core/constants/app_constants.dart';
import 'package:flutter_pro_test/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(SimpleRealtimeTestApp());
}

class SimpleRealtimeTestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Real-time Booking Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: SimpleRealtimeTestScreen(),
    );
  }
}

class SimpleRealtimeTestScreen extends StatefulWidget {
  @override
  _SimpleRealtimeTestScreenState createState() => _SimpleRealtimeTestScreenState();
}

class _SimpleRealtimeTestScreenState extends State<SimpleRealtimeTestScreen> {
  late RealtimeBookingService _realtimeService;
  late RealtimeBookingBloc _realtimeBloc;
  String? _currentBookingId;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  void _initializeServices() {
    final firebaseService = FirebaseService();
    final notificationService = NotificationService();
    _realtimeService = RealtimeBookingService(firebaseService, notificationService);
    _realtimeBloc = RealtimeBookingBloc(_realtimeService);
  }

  @override
  void dispose() {
    _realtimeBloc.close();
    super.dispose();
  }

  void _startTracking() {
    final bookingId = 'test_booking_${DateTime.now().millisecondsSinceEpoch}';
    setState(() {
      _currentBookingId = bookingId;
    });
    _realtimeBloc.add(StartRealtimeTrackingEvent(bookingId));
  }

  void _stopTracking() {
    if (_currentBookingId != null) {
      _realtimeBloc.add(StopRealtimeTrackingEvent(_currentBookingId!));
      setState(() {
        _currentBookingId = null;
      });
    }
  }

  void _updateStatus(String status) {
    if (_currentBookingId != null) {
      _realtimeBloc.add(UpdateBookingStatusEvent(
        bookingId: _currentBookingId!,
        status: status,
        message: 'Status updated to $status',
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Simple Real-time Booking Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: BlocProvider(
        create: (context) => _realtimeBloc,
        child: BlocBuilder<RealtimeBookingBloc, RealtimeBookingState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Real-time Booking Test',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Current Booking ID: ${_currentBookingId ?? 'None'}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'State: ${state.runtimeType}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  // Control buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _currentBookingId == null ? _startTracking : null,
                          child: Text('Start Tracking'),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _currentBookingId != null ? _stopTracking : null,
                          child: Text('Stop Tracking'),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Status update buttons
                  if (_currentBookingId != null) ...[
                    Text(
                      'Update Status:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ElevatedButton(
                          onPressed: () => _updateStatus('pending'),
                          child: Text('Pending'),
                        ),
                        ElevatedButton(
                          onPressed: () => _updateStatus('confirmed'),
                          child: Text('Confirmed'),
                        ),
                        ElevatedButton(
                          onPressed: () => _updateStatus('in_progress'),
                          child: Text('In Progress'),
                        ),
                        ElevatedButton(
                          onPressed: () => _updateStatus('completed'),
                          child: Text('Completed'),
                        ),
                      ],
                    ),
                  ],
                  
                  SizedBox(height: 16),
                  
                  // State display
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Real-time State:',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            SizedBox(height: 8),
                            Expanded(
                              child: SingleChildScrollView(
                                child: _buildStateDisplay(state),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStateDisplay(RealtimeBookingState state) {
    switch (state.runtimeType) {
      case RealtimeBookingInitial:
        return Text('Initial state - no tracking active');
      case RealtimeBookingLoading:
        return Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 8),
            Text('Initializing real-time tracking...'),
          ],
        );
      case RealtimeBookingTracking:
        final trackingState = state as RealtimeBookingTracking;
        return Text('Tracking booking: ${trackingState.bookingId}');
      case RealtimeBookingUpdated:
        final updatedState = state as RealtimeBookingUpdated;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Booking ID: ${updatedState.data.bookingId}'),
            Text('Status: ${updatedState.data.status}'),
            Text('Last Updated: ${updatedState.data.lastUpdated}'),
            Text('Partner En Route: ${updatedState.data.isPartnerEnRoute}'),
            if (updatedState.data.partnerLocation != null)
              Text('Partner Location: ${updatedState.data.partnerLocation!.latitude}, ${updatedState.data.partnerLocation!.longitude}'),
            if (updatedState.data.estimatedArrival != null)
              Text('Estimated Arrival: ${updatedState.data.estimatedArrival}'),
            if (updatedState.data.messages.isNotEmpty) ...[
              SizedBox(height: 8),
              Text('Messages:'),
              ...updatedState.data.messages.map((msg) => 
                Text('- ${msg.message} (${msg.timestamp})')),
            ],
          ],
        );
      case RealtimeBookingError:
        final errorState = state as RealtimeBookingError;
        return Column(
          children: [
            Icon(Icons.error, color: Colors.red, size: 48),
            SizedBox(height: 8),
            Text(
              'Error: ${errorState.message}',
              style: TextStyle(color: Colors.red),
            ),
          ],
        );
      default:
        return Text('Unknown state: ${state.runtimeType}');
    }
  }
}
