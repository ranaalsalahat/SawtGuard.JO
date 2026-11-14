
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:vibration/vibration.dart';
import 'api_service.dart';

void main() {
  runApp(const SawtGuardApp());
}

class SawtGuardApp extends StatelessWidget {
  const SawtGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SawtGuard JO',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

// ================= HOME PAGE =================

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('SawtGuard JO'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.security,
                size: 90,
                color: Colors.teal,
              ),
              const SizedBox(height: 20),
              const Text(
                'Welcome to SawtGuard JO',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Your safety, our priority',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DeepfakePage(),
                    ),
                  );
                },
                icon: const Icon(Icons.graphic_eq),
                label: const Text('Audio Deepfake Detection'),
              ),
              const SizedBox(height: 15),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const SoundRecognitionPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.hearing),
                label: const Text('Smart Sound Recognition'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= DEEPFAKE PAGE =================

class DeepfakePage extends StatefulWidget {
  const DeepfakePage({super.key});

  @override
  State<DeepfakePage> createState() => _DeepfakePageState();
}

class _DeepfakePageState extends State<DeepfakePage> {
  String? selectedFileName;
  String? selectedFilePath;

  Map<String, dynamic>? apiResult;
  String? apiError;
  String? demoResult;

  bool isLoading = false;

  // SELECT AUDIO FILE

  Future<void> pickAudioFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav'],
      );

      if (!mounted) return;

      if (result != null) {
        final file = result.files.single;

        setState(() {
          selectedFileName = file.name;
          selectedFilePath = file.path;
          apiResult = null;
          apiError = null;
          demoResult = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Audio file selected successfully!',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not select the audio file.',
          ),
        ),
      );
    }
  }

  // SEND AUDIO TO BACKEND

  Future<void> analyzeAudio() async {
    if (selectedFilePath == null || isLoading) {
      return;
    }

    setState(() {
      isLoading = true;
      apiResult = null;
      apiError = null;
      demoResult = null;
    });

    try {
      final result = await ApiService.analyzeDeepfake(
        selectedFilePath!,
      );

      if (!mounted) return;

      setState(() {
        apiResult = result;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        apiError = ApiService.baseUrl.isEmpty
            ? 'Backend URL is not configured yet.'
            : 'Could not analyze audio: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // DEMO RESULT BUTTONS

  void showDemoResult(String result) {
    if (isLoading) return;

    setState(() {
      demoResult = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isReal = demoResult == 'Real Audio';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Audio Deepfake Detection'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 25,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.graphic_eq,
                size: 90,
                color: Colors.teal,
              ),
              const SizedBox(height: 15),
              const Text(
                'Detect Fake Audio',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Upload an audio file to check if it is real or AI-generated.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 25),

              ElevatedButton.icon(
                onPressed: isLoading ? null : pickAudioFile,
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload Audio File'),
              ),

              const SizedBox(height: 18),

              if (selectedFileName != null) ...[
                Text(
                  'Selected file: $selectedFileName',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.teal,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 15),

                ElevatedButton.icon(
                  onPressed: isLoading ||
                          selectedFilePath == null
                      ? null
                      : analyzeAudio,
                  icon: const Icon(Icons.analytics),
                  label: const Text('Analyze Audio'),
                ),
              ],

              if (isLoading) ...[
                const SizedBox(height: 22),
                const CircularProgressIndicator(),
                const SizedBox(height: 10),
                const Text(
                  'Uploading audio to backend...',
                ),
              ],

              const SizedBox(height: 24),

              // BACKEND RESULT

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.teal.shade200,
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.insights,
                      color: Colors.teal,
                      size: 38,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'AI Analysis Result',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Text(
                      isLoading
                          ? 'Waiting for backend response...'
                          : apiError != null
                              ? apiError!
                              : apiResult != null
                                  ? 'Backend response: $apiResult'
                                  : 'No backend result available yet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: apiError != null
                            ? Colors.red
                            : Colors.black54,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Backend results may be Mock. Real AI models are not connected yet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 15),

              // DEMO PREVIEW

              const Text(
                'Demo Result Preview',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Preview only - no AI model is connected.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 18),

              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 10,
                children: [
                  OutlinedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () => showDemoResult(
                              'Real Audio',
                            ),
                    icon: const Icon(
                      Icons.check_circle_outline,
                    ),
                    label: const Text('Preview Real'),
                  ),
                  OutlinedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () => showDemoResult(
                              'AI-Generated',
                            ),
                    icon: const Icon(
                      Icons.warning_amber_rounded,
                    ),
                    label: const Text('Preview AI'),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              if (demoResult == null)
                const Text(
                  'No demo result selected yet.',
                  style: TextStyle(color: Colors.grey),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: isReal
                        ? Colors.green.shade50
                        : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isReal
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        isReal
                            ? Icons.check_circle
                            : Icons.warning_amber_rounded,
                        size: 55,
                        color: isReal
                            ? Colors.green
                            : Colors.orange,
                      ),
                      const SizedBox(height: 12),

                      Text(
                        demoResult!,
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'DEMO ONLY - Not a real analysis result',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= SOUND RECOGNITION =================

class SoundRecognitionPage extends StatefulWidget {
  const SoundRecognitionPage({super.key});

  @override
  State<SoundRecognitionPage> createState() =>
      _SoundRecognitionPageState();
}

class _SoundRecognitionPageState
    extends State<SoundRecognitionPage> {
  String? selectedSound;

  bool largeText = false;
  bool highContrast = false;

  // SIMULATE SOUND AND VIBRATION

  Future<void> simulateSound(String sound) async {
    setState(() {
      selectedSound = sound;
    });

    try {
      if (await Vibration.hasVibrator() == true) {
        await Vibration.vibrate(duration: 500);
      }
    } catch (_) {
      // Some emulators do not support vibration.
    }
  }

  Color getAlertColor() {
    switch (selectedSound) {
      case 'Fire Alarm':
        return Colors.red;
      case 'Ambulance Siren':
        return Colors.orange;
      case 'Doorbell':
        return Colors.blue;
      case 'Knocking':
        return Colors.purple;
      default:
        return Colors.teal;
    }
  }

  IconData getAlertIcon() {
    switch (selectedSound) {
      case 'Fire Alarm':
        return Icons.warning_amber_rounded;
      case 'Ambulance Siren':
        return Icons.local_hospital;
      case 'Doorbell':
        return Icons.notifications_active;
      case 'Knocking':
        return Icons.door_front_door;
      default:
        return Icons.notifications_none;
    }
  }

  String getAlertMessage() {
    switch (selectedSound) {
      case 'Fire Alarm':
        return 'Fire Alarm! Please check your surroundings.';
      case 'Ambulance Siren':
        return 'Ambulance Siren! Be aware of emergency vehicles.';
      case 'Doorbell':
        return 'Doorbell! Someone may be at the door.';
      case 'Knocking':
        return 'Knocking! Someone may be knocking.';
      default:
        return 'No sound detected yet.';
    }
  }

  Widget soundButton(
    String title,
    IconData soundIcon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 7,
      ),
      child: ListTile(
        leading: Icon(
          soundIcon,
          color: color,
          size: 32,
        ),
        title: Text(title),
        trailing: const Icon(Icons.touch_app),
        onTap: () => simulateSound(title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color alertColor = getAlertColor();

    final Color alertBackground = highContrast
        ? Colors.black
        : alertColor.withValues(alpha: 0.10);

    final Color alertTextColor =
        highContrast ? Colors.white : alertColor;

    final Color alertBorderColor =
        highContrast ? Colors.white : alertColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Smart Sound Recognition'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 25),

            const Icon(
              Icons.hearing,
              size: 85,
              color: Colors.teal,
            ),

            const SizedBox(height: 15),

            const Text(
              'Sound Recognition',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 24,
              ),
              child: Text(
                'Tap a sound below to preview its alert.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 25),

            // FOUR SOUND BUTTONS

            soundButton(
              'Fire Alarm',
              Icons.warning_amber_rounded,
              Colors.red,
            ),

            soundButton(
              'Ambulance Siren',
              Icons.local_hospital,
              Colors.orange,
            ),

            soundButton(
              'Doorbell',
              Icons.notifications_active,
              Colors.blue,
            ),

            soundButton(
              'Knocking',
              Icons.door_front_door,
              Colors.purple,
            ),

            const SizedBox(height: 20),

            // LARGE TEXT SETTING

            SwitchListTile(
              title: const Text(
                'Large Alert Text',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text(
                'Make alert messages easier to read.',
              ),
              secondary: const Icon(
                Icons.accessibility_new,
                color: Colors.teal,
              ),
              value: largeText,
              activeThumbColor: Colors.teal,
              onChanged: (value) {
                setState(() {
                  largeText = value;
                });
              },
            ),

            // HIGH CONTRAST SETTING

            SwitchListTile(
              title: const Text(
                'High Contrast Mode',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text(
                'Make alerts easier to see.',
              ),
              secondary: const Icon(
                Icons.contrast,
                color: Colors.teal,
              ),
              value: highContrast,
              activeThumbColor: Colors.teal,
              onChanged: (value) {
                setState(() {
                  highContrast = value;
                });
              },
            ),

            const SizedBox(height: 20),

            // ALERT PREVIEW

            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 24,
              ),
              padding: const EdgeInsets.all(24),
              width: double.infinity,
              decoration: BoxDecoration(
                color: alertBackground,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: alertBorderColor,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    getAlertIcon(),
                    color: alertTextColor,
                    size: 60,
                  ),

                  const SizedBox(height: 12),

                  Text(
                    getAlertMessage(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: largeText ? 28 : 20,
                      fontWeight: FontWeight.bold,
                      color: alertTextColor,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'DEMO ONLY - No live sound detection yet.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: highContrast
                          ? Colors.white70
                          : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
