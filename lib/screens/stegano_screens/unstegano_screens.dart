import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class UnSteganoScreen extends StatefulWidget {
  const UnSteganoScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _UnSteganoScreenState createState() => _UnSteganoScreenState();
}

class _UnSteganoScreenState extends State<UnSteganoScreen> {
  File? _selectedEncodedImage;
  String _extractedText = '';
  String _decodedImagePath = '';
  Map<String, dynamic> _decodedImageDetails = {};

  Future<void> _pickEncodedImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedEncodedImage = File(pickedFile.path);
        _extractedText = '';
        _decodedImageDetails = {};
      });
    }
  }

  Future<void> _decodeText() async {
    if (_selectedEncodedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى اختيار صورة مشفرة')),
      );
      return;
    }

    try {
      final imageBytes = await _selectedEncodedImage!.readAsBytes();
      final image = img.decodeImage(imageBytes);

      if (image == null) {
        throw Exception('فشل في تحميل الصورة');
      }

      final extractedText = _extractTextFromImage(image);

      setState(() {
        _extractedText = extractedText;
        _decodedImageDetails = {
          'extracted_text': extractedText,
          'decoded_date': DateTime.now().toString(),
          'image_path': _selectedEncodedImage!.path,
          'text_length': '${extractedText.length} حرف',
          'image_size': '${image.width} x ${image.height}',
        };
      });

      if (extractedText.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('لم يتم العثور على نص مخفي في الصورة')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم فك التعمية بنجاح - النص: "$extractedText"')),
        );
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ في فك التعمية: $e')),
      );
    }
  }

  String _extractTextFromImage(img.Image image) {
    final textBytes = <int>[];
    int currentByte = 0;
    int bitCount = 0;

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);

        // قنوات الألوان
        final r = pixel.r.toInt() & 0xFF;
        final g = pixel.g.toInt() & 0xFF;
        final b = pixel.b.toInt() & 0xFF;

        // استخراج البتات من كل قناة (بنفس الترتيب الذي تم الإخفاء به)
        final channels = [r, g, b];

        for (final channel in channels) {
          // أخذ أقل بت مهم (LSB)
          final bit = channel & 1;

          // إضافة البت إلى البايت الحالي
          currentByte = (currentByte << 1) | bit;
          bitCount++;

          // عندما نصل إلى 8 بت، نضيف البايت إلى النص
          if (bitCount == 8) {
            // إذا كان البايت صفراً، فهذا يعني نهاية النص
            if (currentByte == 0) {
              return String.fromCharCodes(textBytes);
            }

            textBytes.add(currentByte);
            currentByte = 0;
            bitCount = 0;
          }
        }
      }
    }

    // إذا انتهت الصورة ولم نجد نهاية النص، نرجع ما استخرجناه
    return String.fromCharCodes(textBytes);
  }

  // طريقة بديلة أكثر دقة تستخدم نفس منطق الإخفاء تماماً
  String _extractTextFromImageV2(img.Image image) {
    List<int> textBytes = [];
    int byteIndex = 0;
    int bitIndex = 0;
    int currentByte = 0;

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r.toInt() & 0xFF;
        final g = pixel.g.toInt() & 0xFF;
        final b = pixel.b.toInt() & 0xFF;

        // استخراج 3 بتات من هذا البكسل (بنفس ترتيب الإخفاء)
        for (int channelIndex = 0; channelIndex < 3; channelIndex++) {
          if (bitIndex < 8) {
            int bit;
            switch (channelIndex) {
              case 0: bit = r & 1; break;
              case 1: bit = g & 1; break;
              case 2: bit = b & 1; break;
              default: bit = 0;
            }

            // بناء البايت من اليسار إلى اليمين
            currentByte = (currentByte << 1) | bit;
            bitIndex++;

            // إذا اكتمل البايت
            if (bitIndex == 8) {
              // إذا كان البايت صفراً، نهاية النص
              if (currentByte == 0) {
                return String.fromCharCodes(textBytes);
              }
              textBytes.add(currentByte);
              currentByte = 0;
              bitIndex = 0;
            }
          }
        }
      }
    }

    return String.fromCharCodes(textBytes);
  }

  // دالة فك تعمية شاملة تجرب جميع الطرق
  Future<void> _decodeComprehensive() async {
    if (_selectedEncodedImage == null) return;

    try {
      final imageBytes = await _selectedEncodedImage!.readAsBytes();
      final image = img.decodeImage(imageBytes);

      if (image == null) return;

      String result1 = _extractTextFromImage(image);
      String result2 = _extractTextFromImageV2(image);

      // نختار النتيجة الأطول (الأكثر احتمالية للصحة)
      String bestResult = result1.length >= result2.length ? result1 : result2;

      setState(() {
        _extractedText = bestResult;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('الفك الشامل: "$bestResult" (الطريقة 1: "$result1", الطريقة 2: "$result2")')),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في الفك الشامل: $e')),
      );
    }
  }

  Future<void> _saveDecodedImage() async {
    if (_selectedEncodedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى اختيار صورة أولاً')),
      );
      return;
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final decodedPath = '${directory.path}/decoded_image_$timestamp.png';

      await _selectedEncodedImage!.copy(decodedPath);

      setState(() {
        _decodedImagePath = decodedPath;
        _decodedImageDetails['saved_path'] = decodedPath;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم حفظ الصورة في: $decodedPath')),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ في الحفظ: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      color: Color(0xFF101622),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_selectedEncodedImage != null)
              Card(
                color: Color(0xFF333333),
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'الصورة المشفرة المختارة',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white),
                      ),
                      SizedBox(height: 10),
                      Image.file(_selectedEncodedImage!, height: 200, fit: BoxFit.cover),
                    ],
                  ),
                ),
              ),
      
            SizedBox(height: 20),
      
            Card(
              elevation: 4,
              child: Container(
              decoration: BoxDecoration(
                  color: Colors.tealAccent,
                borderRadius: BorderRadius.all(Radius.circular(10))
              ),
                child: ListTile(
                  leading: Icon(Icons.photo_library,color: Colors.black,),
                  title: Text('اختر صورة مشفرة',style: TextStyle(color: Colors.black),),
                  subtitle: Text(_selectedEncodedImage != null ? 'تم اختيار صورة' : 'لم يتم اختيار صورة',style: TextStyle(color: Colors.black),),
                  trailing: Icon(Icons.arrow_forward_ios,),
                  onTap: _pickEncodedImage,
                ),
              ),
            ),
      
            SizedBox(height: 10),
      
            Card(
              color: Colors.tealAccent,
              elevation: 4,
              child: ListTile(
                leading: Icon(Icons.lock_open, color: Colors.black),
                title: Text('فك التعمية (الطريقة 1)'),
                onTap: _decodeText,
              ),
            ),
      
            SizedBox(height: 10),
      
            Card(
              color: Colors.tealAccent,
              elevation: 4,
              child: ListTile(
                leading: Icon(Icons.lock_open, color: Colors.black),
                title: Text('فك التعمية (الطريقة 2)'),
                onTap: () {
                  if (_selectedEncodedImage == null) return;
                  try {
                    final imageBytes = _selectedEncodedImage!.readAsBytesSync();
                    final image = img.decodeImage(imageBytes);
                    if (image != null) {
                      final extractedText = _extractTextFromImageV2(image);
                      setState(() {
                        _extractedText = extractedText;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('الطريقة 2: "$extractedText"')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('خطأ في الطريقة 2: $e')),
                    );
                  }
                },
              ),
            ),
      
            SizedBox(height: 10),
      
            Card(
              color: Colors.tealAccent,
              elevation: 4,
              child: ListTile(
                leading: Icon(Icons.all_inclusive, color: Colors.black),
                title: Text('فك تعمية شامل (يجرب جميع الطرق)'),
                onTap: _decodeComprehensive,
              ),
            ),
      
            SizedBox(height: 20),
      
            if (_extractedText.isNotEmpty)
              Card(
                color: Color(0xFF333333),
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'النص المستخرج',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: Colors.white,
                          border: Border.all(color: Colors.green),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SelectableText(
                          _extractedText,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text('عدد الأحرف: ${_extractedText.length}',style: TextStyle(color: Colors.white),),
                      if (_extractedText.runes.length != _extractedText.length)
                        Text('عدد الرموز Unicode: ${_extractedText.runes.length}'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}