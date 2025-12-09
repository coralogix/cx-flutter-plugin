import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cx_flutter_plugin/cx_flutter_plugin.dart';

/// Model that describes a masked region on the screen.
class MaskRegion {
  final String id; // unique per widget instance
  final double x;
  final double y;
  final double width;
  final double height;
  final bool isMasked;

  MaskRegion({
    required this.id,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.isMasked,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'x': x,
        'y': y,
        'width': width,
        'height': height,
        'isMasked': isMasked,
      };
}

/// Push-based bridge: every region update is immediately sent to native.
class SessionReplayMasking {
  static Future<void> registerRegion(MaskRegion region) async {
    try {
      await CxFlutterPlugin.registerMaskRegion(region.toJson());
    } catch (_) {
      // Swallow errors; masking is best-effort only.
    }
  }

  static Future<void> unregisterRegion(String id) async {
    try {
      await CxFlutterPlugin.unregisterMaskRegion(id);
    } catch (_) {
      // Best-effort.
    }
  }
}

/// Wrap any widget that should be masked in Session Replay.
class MaskedWidget extends StatefulWidget {
  final Widget child;
  final bool isMasked;

  const MaskedWidget({
    super.key,
    required this.child,
    this.isMasked = true,
  });

  @override
  State<MaskedWidget> createState() => _MaskedWidgetState();
}

class _MaskedWidgetState extends State<MaskedWidget> {
  final GlobalKey _key = GlobalKey();
  late final String _id;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _id = _generateId();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reportRect());
  }

  @override
  void dispose() {
    SessionReplayMasking.unregisterRegion(_id);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MaskedWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-measure on rebuild (layout might have changed).
    WidgetsBinding.instance.addPostFrameCallback((_) => _reportRect());
  }

  String _generateId() =>
      '${DateTime.now().microsecondsSinceEpoch}_${_random.nextInt(1 << 32)}';

  void _reportRect() {
    final ctx = _key.currentContext;
    if (ctx == null) return;

    final renderBox = ctx.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.attached) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    final region = MaskRegion(
      id: _id,
      x: offset.dx,
      y: offset.dy,
      width: size.width,
      height: size.height,
      isMasked: widget.isMasked,
    );

    SessionReplayMasking.registerRegion(region);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _key,
      child: widget.child,
    );
  }
}
