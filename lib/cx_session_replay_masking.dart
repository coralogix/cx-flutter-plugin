import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cx_flutter_plugin/cx_flutter_plugin.dart';
import 'package:flutter/services.dart';

class SessionReplayMasking {
  @visibleForTesting
  static const methodChannel = MethodChannel('cx_flutter_plugin');

  static void initialize() {
    methodChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'getMaskRegions':
          final ids = (call.arguments as List).cast<String>();
          return _MaskRegistry.instance.getRegions(ids);
        default:
          throw PlatformException(
            code: 'unimplemented',
            message: 'Method ${call.method} not implemented',
          );
      }
    });
  }

  static Future<void> registerRegion(String id) async {
    try {
      await CxFlutterPlugin.registerMaskRegion(id);
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
  static final Random _random = Random();
  final GlobalKey _key = GlobalKey();
  late final String _id;

  @override
  void initState() {
    super.initState();
    _id = _generateId();

    // local registry entry (for pull-based rect queries)
    _MaskRegistry.instance.add(_id, _key, () => widget.isMasked);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      SessionReplayMasking.registerRegion(_id);
    });
  }

  @override
  void dispose() {
    _MaskRegistry.instance.remove(_id);
    SessionReplayMasking.unregisterRegion(_id);
    super.dispose();
  }

  String _generateId() => '${DateTime.now().microsecondsSinceEpoch}_${_random.nextInt(1 << 32)}';

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _key,
      child: widget.child,
    );
  }
}

class _MaskRegistry {
  static final _MaskRegistry instance = _MaskRegistry._();
  _MaskRegistry._();

  // id -> key + isMasked getter (so it can change)
  final Map<String, _Entry> _entries = {};

  void add(String id, GlobalKey key, bool Function() isMasked) {
    _entries[id] = _Entry(key, isMasked);
  }

  void remove(String id) {
    _entries.remove(id);
  }

  List<Map<String, dynamic>> getRegions(List<String> ids) {
    final List<Map<String, dynamic>> out = [];
    for (final id in ids) {
      final entry = _entries[id];
      if (entry == null) continue;
      if (!entry.isMasked()) continue;

      final ctx = entry.key.currentContext;
      if (ctx == null) continue;

      final ro = ctx.findRenderObject();
      if (ro is! RenderBox || !ro.attached) continue;

      final offset = ro.localToGlobal(Offset.zero);
      final size = ro.size;

      // iOS uses points (logical pixels), Android needs physical pixels
      final dpr = Platform.isIOS ? 1.0 : View.of(ctx).devicePixelRatio;

      out.add({
        'id': id,
        'x': offset.dx,
        'y': offset.dy,
        'width': size.width,
        'height': size.height,
        'dpr': dpr
      });
    }
    return out;
  }
}

class _Entry {
  final GlobalKey key;
  final bool Function() isMasked;
  _Entry(this.key, this.isMasked);
}