import 'dart:io';
import 'dart:math' as math;
import 'transilation_image_class.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:exif/exif.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

class ImageAnalysisTab extends StatefulWidget {
  const ImageAnalysisTab({super.key});

  @override
  _ImageAnalysisTabState createState() => _ImageAnalysisTabState();
}

class _ImageAnalysisTabState extends State<ImageAnalysisTab> {
  String _analysisResult = 'No image analyzed yet';
  bool _isAnalyzing = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImageFromGallery() async {
    try {
      XFile? image;
      image = await _picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        await _analyzeImage(File(image.path));
      } else {
        setState(() {
          _analysisResult = 'No image selected for analysis';
        });
      }
    } catch (e) {
      setState(() {
        _analysisResult = 'Error selecting image: $e';
      });
    }
  }

  Future<void> _analyzeImage(File imageFile) async {
    setState(() {
      _selectedImage = imageFile;
      _isAnalyzing = true;
      _analysisResult = 'Analyzing image...';
    });

    try {
      List<int> imageBytes = await imageFile.readAsBytes();
      String result = await _performImageAnalysis(imageBytes, imageFile.path);

      setState(() {
        _analysisResult = result;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        _analysisResult = 'Error analyzing image: $e';
        _isAnalyzing = false;
      });
    }
  }

  Future<String> _performImageAnalysis(List<int> bytes, String filePath) async {
    String result = '════════ Image Analysis ════════\n\n';

    result += '📷 Basic Information:\n';
    result += '────────────────────\n';
    result += '📁 Path: $filePath\n';
    result += '📊 Size: ${_formatFileSize(bytes.length)}\n\n';

    result += '🖼️ Pixel Analysis:\n';
    result += '────────────────────\n';
    result += await _analyzeWithImageLibrary(bytes);

    result += '\n📋 EXIF Data:\n';
    result += '────────────────────\n';
    result += await _analyzeExifData(bytes);

    result += '\n🔐 Hash Analysis:\n';
    result += '────────────────────\n';
    result += 'MD5: ${md5.convert(bytes)}\n';
    result += 'SHA-256: ${sha256.convert(bytes)}\n';

    result += '\n🔍 Hidden Data Analysis:\n';
    result += '────────────────────\n';
    result += _analyzeForHiddenData(bytes);

    return result;
  }

  Future<String> _analyzeWithImageLibrary(List<int> bytes) async {
    try {
      Uint8List uint8List = Uint8List.fromList(bytes);
      img.Image? image = img.decodeImage(uint8List);
      if (image == null) return '❌ Cannot decode image\n';

      String analysis = '';
      analysis += '📐 Dimensions: ${image.width} × ${image.height} pixels\n';
      analysis += '🎨 Channels: ${image.numChannels} channel\n';
      analysis += '📝 Format: ${_getImageFormat(image)}\n';

      analysis += '🌈 Color Analysis:\n';
      analysis += '  - Depth: ${image.bitsPerChannel} bits per channel\n';
      analysis += '  - Transparency: ${image.palette != null ? 'Color palette' : 'No'}\n';

      analysis += '🔍 Pixel Samples (3×3 from corner):\n';
      for (int y = 0; y < math.min(3, image.height); y++) {
        analysis += '  ';
        for (int x = 0; x < math.min(3, image.width); x++) {
          int color = image.getPixel(x, y) as int;
          String hex = color.toRadixString(16).padLeft(8, '0');
          analysis += '#${hex.substring(2)} ';
        }
        analysis += '\n';
      }

      return analysis;
    } catch (e) {
      return '❌ Error analyzing image: $e\n';
    }
  }

  String _getImageFormat(img.Image image) {
    if (image.bitsPerChannel == 8) return '8-bit RGB';
    if (image.bitsPerChannel == 16) return '16-bit RGB';
    if (image.bitsPerChannel == 32) return '32-bit Float';
    return '${image.bitsPerChannel}-bit Unknown';
  }

  Future<String> _analyzeExifData(List<int> bytes) async {
    try {
      Uint8List uint8List = Uint8List.fromList(bytes);
      final data = await readExifFromBytes(uint8List);

      if (data.isEmpty) return '⚠️ No EXIF data found\n';

      String analysis = '';
      int count = 0;

      for (final entry in data.entries) {
        if (count >= 10) {
          analysis += '... and more\n';
          break;
        }

        String key = entry.key;
        String value = entry.value.toString();

        if (key.contains('Image Description')) key = 'Image Description';
        else if (key.contains('Make')) key = 'Manufacturer';
        else if (key.contains('Model')) key = 'Camera Model';
        else if (key.contains('DateTime')) key = 'Capture Date';
        else if (key.contains('GPS')) key = 'Location Data';

        analysis += '  • $key: $value\n';
        count++;
      }

      return analysis.isEmpty ? '⚠️ No readable EXIF data\n' : analysis;
    } catch (e) {
      return '⚠️ Cannot read EXIF data: $e\n';
    }
  }

  String _analyzeForHiddenData(List<int> bytes) {
    String analysis = '';

    if (bytes.length > 100) {
      List<int> sample = bytes.sublist(0, math.min(1000, bytes.length));

      int lsbZeroCount = 0;
      int lsbOneCount = 0;

      for (int byte in sample) {
        if ((byte & 1) == 0) lsbZeroCount++;
        else lsbOneCount++;
      }

      double ratio = lsbOneCount / (lsbZeroCount + lsbOneCount);
      analysis += '📊 LSB Ratio: ${(ratio * 100).toStringAsFixed(1)}%\n';

      if (ratio > 0.6 || ratio < 0.4) {
        analysis += '⚠️ Unusual activity - may contain hidden data\n';
      } else {
        analysis += '✅ Normal ratio - no obvious hidden data\n';
      }
    }

    if (bytes.length > 50) {
      List<int> endBytes = bytes.sublist(bytes.length - 50);
      analysis += '🔚 End Bytes: ${endBytes.map((b) => b.toRadixString(16)).join(' ')}\n';

      if (String.fromCharCodes(endBytes).contains('EOF') ||
          endBytes.any((b) => b > 127)) {
        analysis += '⚠️ May contain additional data\n';
      }
    }

    return analysis;
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB"];
    int i = (math.log(bytes) / math.log(1024)).floor();
    return '${(bytes / math.pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      color: Color(0xFF121212),
      child: Column(
        children: [
          // Card for image upload
          Card(
            elevation: 0,
            color: Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Color(0xFF333333), width: 1),
            ),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Color(0xFF2D2D2D),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.photo_library,
                      size: 30,
                      color: Colors.tealAccent,
                    ),
                  ),
                  SizedBox(height: 16),
                  TranslatedText(
                    englishText: 'Upload Image for Analysis',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  TranslatedText(
                    englishText: 'Select an image from gallery to analyze',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFB0B0B0),
                    ),
                    align: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _isAnalyzing ? null : _pickImageFromGallery,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.tealAccent,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: _isAnalyzing
                            ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                        )
                            : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.upload, size: 18, color: Colors.black),
                            SizedBox(width: 8),
                            TranslatedText(englishText: 'Upload Image'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_selectedImage != null) ...[
                    SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(0xFF1B5E20),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Color(0xFF4CAF50)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 16),
                          SizedBox(width: 8),
                          Expanded(
                            child: TranslatedText(
                              englishText: 'Selected image: ${_selectedImage!.path.split('/').last}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          SizedBox(height: 20),

          // Results container
          Expanded(
            child: Card(
              elevation: 0,
              color: Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Color(0xFF333333), width: 1),
              ),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.analytics, size: 20, color: Colors.tealAccent),
                        SizedBox(width: 8),
                        TranslatedText(
                          englishText: 'Analysis Results',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Divider(height: 1, color: Color(0xFF333333)),
                    SizedBox(height: 12),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(0xFF121212),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Color(0xFF333333)),
                        ),
                        child: SingleChildScrollView(
                          child: Text(
                            _analysisResult,
                            style: TextStyle(
                              fontFamily: 'Courier',
                              fontSize: 12,
                              height: 1.5,
                              color: Color(0xFFE0E0E0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

