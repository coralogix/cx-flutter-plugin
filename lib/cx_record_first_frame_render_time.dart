import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

class WarmStartTracker with WidgetsBindingObserver {
  DateTime? _resumeStartTime;
  bool _hasRecordedColdStart = false;
  MethodChannel? _channel;

  void init(MethodChannel channel) {  
    _channel = channel;
    WidgetsBinding.instance.addObserver(this);

    // Record cold start when first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasRecordedColdStart) {
        _hasRecordedColdStart = true;
        final coldStartTime = DateTime.now().millisecondsSinceEpoch.toDouble();
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
        final resumeTime = _resumeStartTime;
        if (resumeTime == null) return;

        final renderTime = DateTime.now();
        final duration = renderTime.difference(resumeTime);
        final durationInMilliseconds = duration.inMilliseconds.toDouble();
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
