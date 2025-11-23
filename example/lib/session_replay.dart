import 'package:cx_flutter_plugin/cx_flutter_plugin.dart';
import 'package:cx_flutter_plugin/cx_session_replay_masking.dart';
import 'package:cx_flutter_plugin/cx_session_replay_options.dart';
import 'package:flutter/material.dart';

class SessionReplayOptionsPage extends StatefulWidget {
  const SessionReplayOptionsPage({super.key});

  @override
  State<SessionReplayOptionsPage> createState() =>
      _SessionReplayOptionsPageState();
}

class _SessionReplayOptionsPageState extends State<SessionReplayOptionsPage> {
  String _response = '';

  void _updateResponse(String newResponse) {
    debugPrint(newResponse);
    setState(() {
      _response = newResponse;
    });
  }

  Future<void> _initializeSessionReplay() async {
    final options = CXSessionReplayOptions(
      captureScale: 0.5,
      captureCompressQuality: 1,
      sessionRecordingSampleRate: 100,
      autoStartSessionRecording: true,
      maskAllTexts: false,
      textsToMask: ['Back', '^Session.*'],
      maskAllImages: false,
    );

    final result = await CxFlutterPlugin.initializeSessionReplay(options);
    _updateResponse(result ?? 'SessionReplay init failed');
  }

  Future<void> _shutdownSessionReplay() async {
    await CxFlutterPlugin.shutdownSessionReplay();
    _updateResponse('SessionReplay shutdown success');
  }

  Future<void> _isSessionReplayInited() async {
    final isInited = await CxFlutterPlugin.isSessionReplayInitialized();
    _updateResponse('SessionReplay inited: $isInited');
  }

  Future<void> _isSessionReplayRecording() async {
    final isRecording = await CxFlutterPlugin.isRecording();
    _updateResponse('SessionReplay recording: $isRecording');
  }

  Future<void> _startRecording() async {
    await CxFlutterPlugin.startSessionRecording();
    _updateResponse('SessionReplay recording started');
  }

  Future<void> _stopRecording() async {
    await CxFlutterPlugin.stopSessionRecording();
    _updateResponse('SessionReplay recording stopped');
  }

  Future<void> _captureManualScreenshot() async {
    await CxFlutterPlugin.captureScreenshot();
    _updateResponse('Manual screenshot captured (if available)');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const MaskedWidget(
          child: Text(
            'Session Replay Options',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primaryContainer,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSection(
                context,
                'Initialization',
                Icons.play_arrow,
                [
                  _ModernButton(
                    icon: Icons.power_settings_new,
                    label: 'Initialize Session Replay',
                    description: 'Initialize session replay with options',
                    onPressed: _initializeSessionReplay,
                    color: Colors.green,
                  ),
                  _ModernButton(
                    icon: Icons.power_off,
                    label: 'Shutdown Session Replay',
                    description: 'Shutdown session replay',
                    onPressed: _shutdownSessionReplay,
                    color: Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                context,
                'Status',
                Icons.info,
                [
                  _ModernButton(
                    icon: Icons.check_circle_outline,
                    label: 'Is SessionReplay Inited',
                    description: 'Check if session replay is initialized',
                    onPressed: _isSessionReplayInited,
                    color: Colors.blue,
                  ),
                  _ModernButton(
                    icon: Icons.radio_button_checked,
                    label: 'Is SessionReplay Recording',
                    description: 'Check if session replay is recording',
                    onPressed: _isSessionReplayRecording,
                    color: Colors.orange,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                context,
                'Recording Control',
                Icons.videocam,
                [
                  _ModernButton(
                    icon: Icons.play_circle,
                    label: 'Start Session Recording',
                    description: 'Start recording session',
                    onPressed: _startRecording,
                    color: Colors.teal,
                  ),
                  _ModernButton(
                    icon: Icons.stop_circle,
                    label: 'Stop Session Recording',
                    description: 'Stop recording session',
                    onPressed: _stopRecording,
                    color: Colors.deepOrange,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                context,
                'Screenshots',
                Icons.camera_alt,
                [
                  _ModernButton(
                    icon: Icons.camera,
                    label: 'Capture Manual Screenshot',
                    description: 'Capture a manual screenshot',
                    onPressed: _captureManualScreenshot,
                    color: Colors.purple,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (_response.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.message,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Response',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _response,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children.map((child) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: child,
                )),
          ],
        ),
      ),
    );
  }
}

class _ModernButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final VoidCallback? onPressed;
  final Color color;

  const _ModernButton({
    required this.icon,
    required this.label,
    required this.description,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: description,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 11,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: color.withOpacity(0.5),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
