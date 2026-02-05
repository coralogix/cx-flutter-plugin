
class CXSessionReplayOptions {
  final double captureScale;
  final double captureCompressQuality;
  final int sessionRecordingSampleRate;
  final bool autoStartSessionRecording;
  final bool? maskAllTexts;
  final List<String>? textsToMask;
  final bool? maskAllImages;

  CXSessionReplayOptions({
    required this.captureScale,
    required this.captureCompressQuality,
    required this.sessionRecordingSampleRate,
    required this.autoStartSessionRecording,
    this.maskAllTexts,
    this.textsToMask,
    this.maskAllImages,
  });

  // Optional: Convert to Map (useful for passing to native platform channels)
  Map<String, dynamic> toMap() {
    return {
      "captureScale": captureScale,
      "captureCompressionQuality": captureCompressQuality, // iOS expects "captureCompressionQuality"
      "sessionRecordingSampleRate": sessionRecordingSampleRate,
      "autoStartSessionRecording": autoStartSessionRecording,
      "maskAllTexts": maskAllTexts,
      "textsToMask": textsToMask,
      "maskAllImages": maskAllImages,
    };
  }

  // Optional: Create from Map
  factory CXSessionReplayOptions.fromMap(Map<String, dynamic> map) {
    return CXSessionReplayOptions(
      captureScale: map["captureScale"],
      captureCompressQuality: map["captureCompressQuality"],
      sessionRecordingSampleRate: map["sessionRecordingSampleRate"],
      autoStartSessionRecording: map["autoStartSessionRecording"],
      maskAllTexts: map["maskAllTexts"],
      textsToMask: (map["textsToMask"] as List?)?.map((e) => e as String).toList(),
      maskAllImages: map["maskAllImages"],
    );
  }
}
