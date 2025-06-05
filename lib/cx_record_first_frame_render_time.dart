import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

class WarmStartTracker with WidgetsBindingObserver {
  DateTime? _resumeStartTime;
  bool _hasRecordedColdStart = false;
  MethodChannel? _channel;

  void init(MethodChannel channel) {  
    _channel = channel;
    WidgetsBinding.instance.addObserver(this);
    const double appleEpochOffset = 978307200; // in seconds

    // Record cold start when first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasRecordedColdStart) {
        _hasRecordedColdStart = true;
        final coldStartTime = DateTime.now().millisecondsSinceEpoch.toDouble() / 1000.0 - appleEpochOffset;
        sendStartUpVital(coldStartTime, 'cold');
      }
    });
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _resumeStartTime = DateTime.now();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final renderTime = DateTime.now();
        final duration = renderTime.difference(_resumeStartTime!);
        final durationInMilliseconds = duration.inMicroseconds / 1000.0;
        sendStartUpVital(durationInMilliseconds, "warm");
      });
    }
  }

  void sendStartUpVital(double duration, String mobileVitalsType) async {
      try {
        debugPrint('🔥 $mobileVitalsType start duration: $duration ms');

        await _channel?.invokeMethod('recordFirstFrameTime', {
          mobileVitalsType: duration,
        });
    } catch (e) {
      debugPrint('❌ Failed to send first frame time: $e');
    }
  }
}
