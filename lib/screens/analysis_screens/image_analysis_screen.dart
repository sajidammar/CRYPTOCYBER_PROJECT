import 'dart:io';
import 'dart:math' as math;
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
  String _analysisResult = 'لم يتم تحليل أي صورة بعد';
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
          _analysisResult = 'لم يتم اختيار أي صورة للتحليل';
        });
      }
    } catch (e) {
      setState(() {
        _analysisResult = 'خطأ في اختيار الصورة: $e';
      });
    }
  }

  Future<void> _analyzeImage(File imageFile) async {
    setState(() {
      _selectedImage = imageFile;
      _isAnalyzing = true;
      _analysisResult = 'جاري تحليل الصورة...';
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
        _analysisResult = 'خطأ في تحليل الصورة: $e';
        _isAnalyzing = false;
      });
    }
  }

  Future<String> _performImageAnalysis(List<int> bytes, String filePath) async {
    String result = '════════ تحليل الصورة ════════\n\n';

    result += '📷 المعلومات الأساسية:\n';
    result += '────────────────────\n';
    result += '📁 المسار: $filePath\n';
    result += '📊 الحجم: ${_formatFileSize(bytes.length)}\n\n';

    result += '🖼️ تحليل البكسلات:\n';
    result += '────────────────────\n';
    result += await _analyzeWithImageLibrary(bytes);

    result += '\n📋 البيانات الوصفية (EXIF):\n';
    result += '────────────────────\n';
    result += await _analyzeExifData(bytes);

    result += '\n🔐 تحليل التجزئة:\n';
    result += '────────────────────\n';
    result += 'MD5: ${md5.convert(bytes)}\n';
    result += 'SHA-256: ${sha256.convert(bytes)}\n';

    result += '\n🔍 تحليل البيانات المخفية:\n';
    result += '────────────────────\n';
    result += _analyzeForHiddenData(bytes);

    return result;
  }

  Future<String> _analyzeWithImageLibrary(List<int> bytes) async {
    try {
      // الحل: تحويل List<int> إلى Uint8List
      Uint8List uint8List = Uint8List.fromList(bytes);
      img.Image? image = img.decodeImage(uint8List);
      if (image == null) return '❌ لا يمكن فك تشفير الصورة\n';

      String analysis = '';
      analysis += '📐 الأبعاد: ${image.width} × ${image.height} بكسل\n';
      analysis += '🎨 القنوات: ${image.numChannels} قناة\n';
      analysis += '📝 التنسيق: ${_getImageFormat(image)}\n';

      analysis += '🌈 تحليل الألوان:\n';
      analysis += '  - العمق: ${image.bitsPerChannel} بت لكل قناة\n';
      analysis += '  - شفافية: ${image.palette != null ? 'لوحة ألوان' : 'لا'}\n';

      analysis += '🔍 عينة البكسلات (3×3 من الزاوية):\n';
      for (int y = 0; y < math.min(3, image.height); y++) {
        analysis += '  ';
        for (int x = 0; x < math.min(3, image.width); x++) {
          // الحل: استخدام getPixel للحصول على اللون ثم تحليله
          int color = image.getPixel(x, y) as int;
          // تحويل اللون إلى تنسيق HEX
          String hex = color.toRadixString(16).padLeft(8, '0');
          analysis += '#${hex.substring(2)} '; // إزالة alpha channel للتبسيط
        }
        analysis += '\n';
      }

      return analysis;
    } catch (e) {
      return '❌ خطأ في تحليل الصورة: $e\n';
    }
  }

  String _getImageFormat(img.Image image) {
    // الحل المبسط: استخدام bitsPerChannel بدلاً من depth
    if (image.bitsPerChannel == 8) return '8-bit RGB';
    if (image.bitsPerChannel == 16) return '16-bit RGB';
    if (image.bitsPerChannel == 32) return '32-bit Float';
    return '${image.bitsPerChannel}-bit غير معروف';
  }

  Future<String> _analyzeExifData(List<int> bytes) async {
    try {
      // الحل: تحويل List<int> إلى Uint8List
      Uint8List uint8List = Uint8List.fromList(bytes);
      final data = await readExifFromBytes(uint8List);

      if (data.isEmpty) return '⚠️ لا توجد بيانات EXIF\n';

      String analysis = '';
      int count = 0;

      for (final entry in data.entries) {
        if (count >= 10) {
          analysis += '... والمزيد\n';
          break;
        }

        String key = entry.key;
        String value = entry.value.toString();

        if (key.contains('Image Description')) key = 'وصف الصورة';
        else if (key.contains('Make')) key = 'الشركة المصنعة';
        else if (key.contains('Model')) key = 'موديل الكاميرا';
        else if (key.contains('DateTime')) key = 'تاريخ الالتقاط';
        else if (key.contains('GPS')) key = 'بيانات الموقع';

        analysis += '  • $key: $value\n';
        count++;
      }

      return analysis.isEmpty ? '⚠️ لا توجد بيانات EXIF قابلة للقراءة\n' : analysis;
    } catch (e) {
      return '⚠️ لا يمكن قراءة بيانات EXIF: $e\n';
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
      analysis += '📊 نسبة LSB: ${(ratio * 100).toStringAsFixed(1)}%\n';

      if (ratio > 0.6 || ratio < 0.4) {
        analysis += '⚠️ نشاط غير عادي - قد تحتوي على بيانات مخفية\n';
      } else {
        analysis += '✅ النسبة طبيعية - لا توجد بيانات مخفية واضحة\n';
      }
    }

    if (bytes.length > 50) {
      List<int> endBytes = bytes.sublist(bytes.length - 50);
      analysis += '🔚 البايتات النهائية: ${endBytes.map((b) => b.toRadixString(16)).join(' ')}\n';

      if (String.fromCharCodes(endBytes).contains('EOF') ||
          endBytes.any((b) => b > 127)) {
        analysis += '⚠️ قد توجد بيانات إضافية\n';
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
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Card(
            color: Color(0xFF1a1a2e),
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                children: [
                  Icon(
                    Icons.add_photo_alternate,
                    size: 50,
                    color: Color(0xFFe94560),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'ارفع صورة للتحليل',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _isAnalyzing ? null : _pickImageFromGallery,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFe94560),
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        child: _isAnalyzing
                            ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                            : Text('من المعرض'),
                      ),
                    ],
                  ),
                  if (_selectedImage != null) ...[
                    SizedBox(height: 10),
                    Text(
                      'الصورة المحددة: ${_selectedImage!.path.split('/').last}',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Color(0xFF1a1a2e),
                border: Border.all(color: Colors.grey[700]!),
                borderRadius: BorderRadius.circular(10),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _analysisResult,
                  style: TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}