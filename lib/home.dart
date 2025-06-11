import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:vibration/vibration.dart';
import 'cubit/object_cubit.dart';
import 'cubit/object_state.dart';
import 'object_model.dart';

class FeatureCardScreen extends StatefulWidget {
  const FeatureCardScreen({super.key});
  @override
  State<FeatureCardScreen> createState() => _FeatureCardScreenState();
}

class _FeatureCardScreenState extends State<FeatureCardScreen> {
  final List<Map<String, String>> features = [
    {
      'title': 'Scene Detection',
      'endpoint': 'scene-detection',
      'description': 'Analyze a scene and get a description',
      'image': 'assets/virus-search.png',
    },
    {
      'title': 'Object Detection',
      'endpoint': 'detect-objects',
      'description': 'Detect objects in the image',
      'image': 'assets/tracking.png',
    },
    {
      'title': 'Safety Alerts',
      'endpoint': 'safety-alerts',
      'description': 'Identify potential hazards in the scene',
      'image': 'assets/reminder.png',
    },
  ];

  late CameraController _cameraController;
  late List<CameraDescription> _cameras;
  late PageController _pageController;
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;

  final ImagePicker _picker = ImagePicker();

  String? selectedEndpoint;
  String _voiceCommand = '';
  String resultText = '';
  String? errorText;

  bool _isCameraInitialized = false;
  bool _isListening = false;
  bool isCapturing = false;
  bool isLoading = false;
  bool _hasSpoken = false;
  bool _isDisposed = false; // متغير للتأكد من أنه تم التخلص من الكاميرا

  Timer? _detectionTimer;
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();

    _initializeCamera(); // تهيئة الكاميرا

    // التحدث برسالة الترحيب عند أول تشغيل
    if (!_hasSpoken) {
      _speakWelcomeMessage();
      _hasSpoken = true;
    }
  }

  // تهيئة الكاميرا
  void _initializeCamera() async {
    try {
      // تهيئة الكاميرا
      _cameraController = CameraController(
        _cameras[0], // استخدم الكاميرا المطلوبة
        ResolutionPreset.high,
      );

      await _cameraController.initialize();

      if (!mounted) return; // تحقق من أنه لا يزال لدينا الصفحة
      setState(() {
        _isCameraInitialized = true; // تأكد من أن الكاميرا تم تهيئتها
      });
    } catch (e) {
      // التعامل مع الأخطاء أثناء التهيئة
      print("Camera initialization failed: $e");
    }
  }

  @override
  void dispose() {
    // إيقاف الكاميرا بشكل صحيح عند مغادرة الصفحة
    _detectionTimer?.cancel();
    _flutterTts.stop();

    if (_cameraController != null) {
      _cameraController.dispose(); // تأكد من التخلص من الكاميرا بشكل صحيح
    }

    _isDisposed = true; // تعيين _isDisposed على true لضمان عدم استخدام الكاميرا بعد التخلص منها
    _pageController.dispose();
    super.dispose();
  }

  Future<bool> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }
    return status.isGranted;
  }

  Future<void> _speakText(String text) async {
    await _flutterTts.setLanguage("en");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(text);
  }

  Future<void> _speakWelcomeMessage() async {
    await _flutterTts.setLanguage('en');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(
      "swipe left or right the top section of screen to select a feature, and double-tap to activate it.",
    );
  }

  Future<void> _speakFeatureTitle(int index) async {
    await _flutterTts.stop();
    await _flutterTts.setLanguage('en');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
    if (index < features.length) {
      String title = features[index]['title'] ?? 'Unknown Feature';
      String description = features[index]['description'] ?? 'No description';
      await _flutterTts.speak("Feature: $title that is  $description ");
    } else {
      await _flutterTts.speak(
        "Feature : Extracted Text that is Read text from image",
      );
    }
  }

  void triggerVibration() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(pattern: [0, 500, 300, 500, 300, 500]);
    } else {
      Fluttertoast.showToast(msg: 'Device not support Vibration');
      await _speakText('Device not support Vibration');
    }
  }

  void _startListening() async {
    var status = await Permission.microphone.request();
    if (!status.isGranted) {
      return;
    }

    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done') {
          setState(() => _isListening = false);
        }
      },
      onError: (error) {
        setState(() => _isListening = false);
      },
    );

    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        localeId: 'en',
        onResult: (result) {
          if (result.finalResult) {
            _handleVoiceCommand(result.recognizedWords);

            _speech.stop();
            Future.delayed(Duration(milliseconds: 500), () {
              if (mounted) _startListening();
            });
          }
        },
      );
    } else {
      print('Speech recognition not available');
    }
  }

  Future<void> _handleVoiceCommand(String command) async {
    command = command.toLowerCase();
    if (command.trim() == 'open') {
      if (!_isListening) {
        _startListening();
        await _speakText('Listening started');
      } else {
        await _speakText('I am already listening');
      }
      return;
    }
    for (var i = 0; i < features.length; i++) {
      final feature = features[i];
      final title = feature['title']!.toLowerCase();

      if (command.contains(title) ||
          title.split(' ').any((word) => command.contains(word))) {
        // لو الميزة دي شغالة أصلاً
        if (_isCameraInitialized && selectedEndpoint == feature['endpoint']) {
          await _speakText('${feature['title']} is already running');
          return;
        }

        await _speakText('Opening ${feature['title']} feature');

        // 🔄 التنقل للسلايدر المناسب
        _pageController.animateToPage(
          i,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );

        // ▶️ تشغيل الكاميرا
        await _toggleCamera(feature['endpoint']!);
        return;
      }
    }

    // استخراج النص
    if (command.contains('read') || command.contains('text')) {
      await _speakText('Opening text extraction');
      _pickAndSend('extract-text');
      return;
    }

    // إيقاف الكاميرا
    if (command.contains('camera')) {
      if (_isCameraInitialized) {
        await _speakText('Stopping the camera');
        await _toggleCamera('');
      }
      return;
    }
    if (command.contains('stop record')) {
      if (_isListening) {
        _speech.stop(); // إيقاف الاستماع
        await _speakText('Stopped listening');
      }
      return;
    }
    // لم يتم التعرف على الأمر الصوتي
    Fluttertoast.showToast(msg: 'Voice command not understood');
    await _speakText('Voice command not understood');
  }


  void _startPeriodicDetection() {
    _detectionTimer?.cancel();
    _detectionTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (_isCameraInitialized && selectedEndpoint != null) {
        _captureAndSendFrame();
      }
    });
  }

  Future<void> _toggleCamera(String endpoint) async {
    if (_isCameraInitialized) {
      await _cameraController.dispose(); // توقف الكاميرا بشكل صحيح
      _detectionTimer?.cancel();
      _isCameraInitialized = false;
      setState(() {
        selectedEndpoint = null;
        resultText = 'Camera stopped.';
        isLoading = false;
      });
      return;
    } else {
      bool hasPermission = await _requestCameraPermission();
      if (!hasPermission) {
        Fluttertoast.showToast(msg: 'Please allow camera permission');
        await _speakText('Please allow camera permission');
        return;
      }

      setState(() {
        selectedEndpoint = endpoint;
        resultText = 'Detecting with: $endpoint';
        isLoading = true;
      });

      await _initCamera(); // إعادة تهيئة الكاميرا
      _startPeriodicDetection();
    }
  }

  Future<void> _initCamera() async {
    if (_isDisposed) return; // Avoid initializing if widget is disposed

    _cameras = await availableCameras();
    _cameraController = CameraController(
      _cameras.first,
      ResolutionPreset.medium,
    );

    try {
      await _cameraController.initialize();
      if (!mounted || _isDisposed) return;

      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      if (!_isDisposed) {
        await _speakText('Failed to initialize the camera: $e');
      }
    }
  }

  Future<void> _captureAndSendFrame() async {
    if (isCapturing || selectedEndpoint == null || _isDisposed) return; // التأكد من أن الكاميرا غير موقوفة
    if (!_cameraController.value.isInitialized || _isDisposed) return; // تأكد من أن الكاميرا مهيأة بشكل صحيح

    isCapturing = true;

    try {
      final XFile file = await _cameraController.takePicture();

      if (_isDisposed || !mounted) return; // تأكد قبل إجراء أي تحديث على الواجهة

      final bytes = await file.readAsBytes();
      final result = await _detectObjects(bytes, selectedEndpoint!);

      if (_isDisposed || !mounted) return;

      if (result != null) {
        setState(() {
          resultText = result['description'] ?? 'No description';
          isLoading = false;
        });

        await _speakText("Image captured and sent for analysis.");

        if (selectedEndpoint == 'safety-alerts') {
          triggerVibration();
        }

        await _speakText(resultText);
      }
    } catch (e) {
      if (!_isDisposed) {
        await _speakText("Error occurred, please try again.");
      }
    } finally {
      isCapturing = false;
    }
  }



  Future<void> _pickAndSend(String endpoint) async {
    bool hasPermission = await _requestCameraPermission();
    if (!hasPermission) {
      Fluttertoast.showToast(msg: 'Please allow camera permission');
      await _speakText('Please allow camera permission');
      return;
    }
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final imageFile = File(picked.path);
      context.read<ObjectCubit>().objects(imageFile, endpoint);
      context.read<ObjectCubit>().stream.listen((state) {
        if (state is ObjectSuccess) {
          if (state.prediction.text != null &&
              state.prediction.text!.isNotEmpty) {
            _speakText("Image sent for analysis.");
            _speakText(state.prediction.text!);
          }
        }
      });
    } else {
      await _speakText("No image selected.");
    }
  }

  Future<Map<String, dynamic>?> _detectObjects(
    List<int> imageBytes,
    String endpoint,
  ) async {
    try {
      final String apiUrl = 'http://192.168.100.3:8000/$endpoint';
      final request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: 'image.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      await _speakText('Error detecting objects: $e');
      return null;
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Vision Features"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 200,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                _speakFeatureTitle(index);
              },
              itemCount: features.length + 1,
              itemBuilder: (context, index) {
                if (index == features.length) {
                  return GestureDetector(
                    onTap: () {
                      context.read<ObjectCubit>().emit(ObjectInitial());
                      setState(() {
                        resultText = '';
                        errorText = null;
                      });
                      _pickAndSend('extract-text');
                    },
                    child: Card(
                      color: const Color(0xFFBDC5DA),
                      margin: const EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Text Extraction',
                              style: TextStyle(
                                color: Color(0xFF3B579A),
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 1),
                            SizedBox(
                              height: 90,
                              width: double.infinity,
                              child: Image.asset(
                                'assets/file.png',
                                height: 50,
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              "Read text from image",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  final feature = features[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: GestureDetector(
                      onTap: () {
                        context.read<ObjectCubit>().emit(ObjectInitial());
                        setState(() {
                          resultText = '';
                          errorText = null;
                        });
                        _toggleCamera(feature['endpoint']!);
                      },
                      child: Card(
                        elevation:
                        selectedEndpoint == feature['endpoint'] ? 10 : 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: selectedEndpoint == feature['endpoint']
                            ? const Color(0xFF7D98D6)
                            : const Color(0xFFBDC5DA),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Title of the feature
                              Text(
                                feature['title']!,
                                style: TextStyle(
                                  color: selectedEndpoint == feature['endpoint']
                                      ? Colors.white
                                      : const Color(0xFF3B579A),
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 1),
                              SizedBox(
                                height: 100,
                                width: double.infinity,
                                child: Image.asset(
                                  feature['image'] != null
                                      ? feature['image']!
                                      : 'assets/default_image.png',
                                  height: 50,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                feature['description']!,
                                style: TextStyle(
                                  color: selectedEndpoint == feature['endpoint']
                                      ? Colors.white70
                                      : Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<ObjectCubit, ObjectPredictionState>(
              builder: (context, state) {
                // التحقق من أن الكاميرا مهيأة ولم يتم التخلص منها
                if (_isCameraInitialized && !_isDisposed && _cameraController.value.isInitialized)
{
                  return Stack(
                    children: [
                      CameraPreview(_cameraController),
                      if (isLoading)
                        const Center(child: CircularProgressIndicator()),
                      if (resultText.isNotEmpty && !isLoading)
                        Positioned(
                          bottom: 20,
                          left: 20,
                          right: 20,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              resultText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                } else if (state is ObjectLoading) {
                  // حالة التحميل
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ObjectSuccess) {
                  // حالة النجاح مع عرض النصوص المستخلصة
                  return _buildPredictionResult(state.prediction);
                } else if (state is ObjectError) {
                  // في حالة الخطأ
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                } else {
                  // الرسالة الافتراضية
                  return const Center(
                    child: Text(
                      "Choose Feature to Start",
                      style: TextStyle(
                        color: Color(0xFF3B579A),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }
              },
            ),
          )]),
      floatingActionButton: FloatingActionButton(
        onPressed: _startListening,
        backgroundColor: const Color(0xFFBDC5DA),
        child: Icon(
          _isListening ? Icons.mic : Icons.mic_none,
          color: const Color(0xFF3B579A),
          size: 20,
        ),
      ),
    );
  }
  Widget _buildPredictionResult(ObjectPrediction prediction) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (prediction.text != null)
              SelectableText(
                "Extracted Text:\n${prediction.text!}",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            if (prediction.description != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text("Description: ${prediction.description!}"),
              ),
            if (prediction.alerts != null && prediction.alerts!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: prediction.alerts!
                      .map((alert) => Text("Alert: $alert", style: const TextStyle(color: Colors.red)))
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
