// FILE: lib/main.dart
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
  
  // Initialize Firebase
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
  // 5 predefined categories
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

  /// Format date as YYYY-MM-DD
  String _formatDateForFilename(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Pick image from camera
  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (photo == null) {
        // User canceled
        return;
      }

      setState(() {
        _imageFile = File(photo.path);
      });
    } catch (e) {
      _showError('Camera error: $e');
    }
  }

  /// Compress image to <= 300 KB if possible
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

      // If still > 300 KB, try lower quality
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

  /// Upload image to Firebase Storage and write metadata to Firestore
  Future<void> _uploadToFirebase(File imageFile, String category) async {
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      // 1. Compress image
      final compressedFile = await _compressImage(imageFile);

      // 2. Generate filename with auto-incrementing counter
      final timestamp = _formatDateForFilename(DateTime.now());
      
      // Query Firestore to find existing files with same date and category
      final querySnapshot = await FirebaseFirestore.instance
          .collection('temp_dockets')
          .where('category', isEqualTo: category)
          .get();

      // Find the highest counter number for today's date
      int maxCounter = -1;
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        if (data['filename'] != null) {
          final filename = data['filename'] as String;
          // Check if filename starts with today's date
          if (filename.startsWith('${timestamp}_${category}_')) {
            // Extract counter from filename: YYYY-MM-DD_Category_X.jpg
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

      // Increment counter
      final newCounter = maxCounter + 1;
      final filename = '${timestamp}_${category}_$newCounter.jpg';

      debugPrint('Uploading file: $filename');

      // 3. Storage path: dockets/[category]/[filename] - each category in its own folder
      final storageRef = FirebaseStorage.instance.ref().child('dockets/${category.toLowerCase()}/$filename');

      // 4. Upload with progress tracking
      final uploadTask = storageRef.putFile(compressedFile);

      // Listen to upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        if (mounted) {
          setState(() {
            _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
          });
        }
      });

      // Wait for upload to complete
      await uploadTask.whenComplete(() {
        debugPrint('Upload task completed');
      });
      
      final snapshot = await uploadTask.snapshot;

      // 5. Get download URL
      final downloadURL = await snapshot.ref.getDownloadURL();
      debugPrint('Upload successful. Download URL: $downloadURL');

      // 6. Detect platform
      final platform = Platform.isAndroid ? 'android' : (Platform.isIOS ? 'ios' : 'macos');

      // 7. Write metadata to Firestore
      debugPrint('Writing to Firestore...');
      await FirebaseFirestore.instance.collection('temp_dockets').add({
        'filename': filename,
        'category': category,
        'storagePath': 'dockets/${category.toLowerCase()}/$filename',
        'downloadURL': downloadURL,
        'createdAt': FieldValue.serverTimestamp(),
        'devicePlatform': platform,
      });
      debugPrint('Firestore write successful');

      // 8. Success: clear image and show message
      debugPrint('Resetting UI state...');
      
      // Force state reset
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
      
      // Ensure state reset on error
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });
      
      if (mounted) {
        _showError('Upload failed: $e');
      }
    } finally {
      // Absolutely ensure state is reset
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

/*
ACCEPTANCE TEST CHECKLIST:
- [ ] Select category defaults to none; Upload disabled until both category and photo are ready.
- [ ] Taking a photo shows its preview.
- [ ] Upload shows progress and ends with success message.
- [ ] Firebase Storage contains file: dockets/temp/[YYYY-MM-DD]_[Category]_0.jpg
- [ ] Firestore temp_dockets has a document with all required fields.
- [ ] App handles canceling camera gracefully.
- [ ] App shows friendly errors when offline or Firebase not set.
*/
