import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }
  
  runApp(const DocketApp());
}

class DocketApp extends StatelessWidget {
  const DocketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maintenance Docket',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1976D2),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: const DocketScreen(),
    );
  }
}

class DocketScreen extends StatefulWidget {
  const DocketScreen({super.key});

  @override
  State<DocketScreen> createState() => _DocketScreenState();
}

class _DocketScreenState extends State<DocketScreen> {
  static const List<String> categories = [
    'Electrical',
    'Plumbing',
    'Cleaning',
    'Security',
    'Other',
  ];

  String? _selectedCategory;
  File? _imageFile;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  final ImagePicker _picker = ImagePicker();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'sltinterntask',
  );

  String _formatDateForFilename(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (photo == null) {
        return;
      }

      setState(() {
        _imageFile = File(photo.path);
      });
    } catch (e) {
      _showError('Camera error: $e');
    }
  }

  Future<File> _compressImage(File file) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = path.join(
        dir.path,
        'compressed_${path.basename(file.path)}',
      );

      // Try compression with quality 85
      XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 85,
      );

      if (compressedFile == null) {
        debugPrint('Compression returned null, using original');
        return file;
      }

      File compressed = File(compressedFile.path);
      int fileSize = await compressed.length();
      debugPrint('Compressed size: ${fileSize / 1024} KB');

      if (fileSize > 300 * 1024) {
        compressedFile = await FlutterImageCompress.compressAndGetFile(
          file.absolute.path,
          targetPath.replaceAll('.jpg', '_low.jpg'),
          quality: 60,
        );
        if (compressedFile != null) {
          compressed = File(compressedFile.path);
          fileSize = await compressed.length();
          debugPrint('Re-compressed size: ${fileSize / 1024} KB');
        }
      }

      return compressed;
    } catch (e) {
      debugPrint('Compression error: $e, using original');
      return file;
    }
  }

  Future<void> _uploadToFirebase(File imageFile, String category) async {
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      final compressedFile = await _compressImage(imageFile);
      final timestamp = _formatDateForFilename(DateTime.now());
      
      final querySnapshot = await _firestore
          .collection('temp_dockets')
          .where('category', isEqualTo: category)
          .get();

      int maxCounter = -1;
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        if (data['filename'] != null) {
          final filename = data['filename'] as String;
          if (filename.startsWith('${timestamp}_${category}_')) {
            final match = RegExp(r'_(\d+)\.jpg$').firstMatch(filename);
            if (match != null) {
              final counter = int.parse(match.group(1)!);
              if (counter > maxCounter) {
                maxCounter = counter;
              }
            }
          }
        }
      }

      final newCounter = maxCounter + 1;
      final filename = '${timestamp}_${category}_$newCounter.jpg';

      debugPrint('Uploading file: $filename');

      final storageRef = FirebaseStorage.instance.ref().child('dockets/${category.toLowerCase()}/$filename');
      final uploadTask = storageRef.putFile(compressedFile);

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        if (mounted) {
          setState(() {
            _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
          });
        }
      });

      await uploadTask.whenComplete(() {
        debugPrint('Upload task completed');
      });
      
      final snapshot = uploadTask.snapshot;
      final downloadURL = await snapshot.ref.getDownloadURL();
      debugPrint('Upload successful. Download URL: $downloadURL');

      final platform = Platform.isAndroid ? 'android' : (Platform.isIOS ? 'ios' : 'macos');

      debugPrint('Writing to Firestore...');
      await _firestore.collection('temp_dockets').add({
        'filename': filename,
        'category': category,
        'storagePath': 'dockets/${category.toLowerCase()}/$filename',
        'downloadURL': downloadURL,
        'createdAt': FieldValue.serverTimestamp(),
        'devicePlatform': platform,
      });
      debugPrint('Firestore write successful');

      debugPrint('Resetting UI state...');
      
      setState(() {
        _imageFile = null;
        _isUploading = false;
        _uploadProgress = 0.0;
      });
      
      debugPrint('State reset complete. _isUploading: $_isUploading');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Complaint Submitted',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'ID: $filename',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF43A047),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Upload error: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
      
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });
      
      if (mounted) {
        _showError('Upload failed: $e');
      }
    } finally {
      if (mounted && _isUploading) {
        debugPrint('Finally block: Force resetting _isUploading');
        setState(() {
          _isUploading = false;
          _uploadProgress = 0.0;
        });
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFD32F2F),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  bool get _canUpload => _selectedCategory != null && _imageFile != null && !_isUploading;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'New Complaint',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Category Selection Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.category_outlined,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Issue Category',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      hint: const Text('Select issue type'),
                      items: categories.map((cat) {
                return DropdownMenuItem(
                  value: cat,
                  child: Text(cat),
                );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Photo Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.photo_camera_outlined,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Photo Evidence',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_imageFile == null)
                      OutlinedButton.icon(
                        onPressed: _isUploading ? null : _pickImageFromCamera,
                        icon: const Icon(Icons.add_a_photo),
                        label: const Text('Capture Photo'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      )
                    else ...[
                      Stack(
                        children: [
                          Container(
                            height: 280,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _imageFile!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          if (!_isUploading)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Material(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(20),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () {
                                    setState(() {
                                      _imageFile = null;
                                    });
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: _isUploading ? null : _pickImageFromCamera,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Retake Photo'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton.icon(
              onPressed: _canUpload
                  ? () => _uploadToFirebase(_imageFile!, _selectedCategory!)
                  : null,
              icon: _isUploading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.upload_rounded),
              label: Text(
                _isUploading ? 'Submitting...' : 'Submit Complaint',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 54),
                backgroundColor: _canUpload
                    ? Theme.of(context).colorScheme.primary
                    : null,
                foregroundColor: Colors.white,
              ),
            ),

            // Upload Progress
            if (_isUploading) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        value: _uploadProgress,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Uploading... ${(_uploadProgress * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

