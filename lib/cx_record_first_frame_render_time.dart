import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

Future<void> recordFirstFrameRenderTime(MethodChannel channel) async {
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final firstFrameTime = DateTime.now().millisecondsSinceEpoch.toDouble() / 1000.0;

    try {
      await channel.invokeMethod('recordFirstFrameTime', {
        'coldEnd': firstFrameTime,
      });
    } catch (e) {
      debugPrint('❌ Failed to send first frame time: $e');
    }
  });
}