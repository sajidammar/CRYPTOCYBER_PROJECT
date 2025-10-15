
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class SteganographyScreen extends StatefulWidget {
  @override
  _SteganographyScreenState createState() => _SteganographyScreenState();
}

class _SteganographyScreenState extends State<SteganographyScreen> {
  File? _selectedImage;
  String _hiddenText = '';
  String _savedImagePath = '';
  Map<String, dynamic> _imageDetails = {};

  final TextEditingController _textController = TextEditingController();

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _loadImageDetails(pickedFile.path);
      });
    }
  }

  void _loadImageDetails(String imagePath) {
    final file = File(imagePath);
    final stat = file.statSync();

    setState(() {
      _imageDetails = {
        'path': imagePath,
        'size': '${(stat.size / 1024).toStringAsFixed(2)} KB',
        'modified': stat.modified.toString(),
        'type': path.extension(imagePath),
      };
    });
  }

  Future<void> _hideTextAndSave() async {
    if (_selectedImage == null || _hiddenText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى اختيار صورة وإدخال نص')),
      );
      return;
    }

    try {
      final imageBytes = await _selectedImage!.readAsBytes();
      final originalImage = img.decodeImage(imageBytes);

      if (originalImage == null) {
        throw Exception('فشل في تحميل الصورة');
      }

      // تحويل النص إلى bytes مع إضافة نهاية النص (0)
      final textBytes = _hiddenText.codeUnits;
      final totalBytes = textBytes.length + 1; // +1 لنهاية النص

      // حساب البتات المطلوبة
      final totalBitsNeeded = totalBytes * 8;
      final totalPixelsNeeded = (totalBitsNeeded / 3).ceil();

      if (totalPixelsNeeded > originalImage.width * originalImage.height) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('الصورة صغيرة جداً لإخفاء هذا النص. تحتاج إلى ${totalPixelsNeeded} بكسل ولكن الصورة تحتوي على ${originalImage.width * originalImage.height} بكسل')),
        );
        return;
      }

      final encodedImage = img.Image.from(originalImage);
      int byteIndex = 0;
      int bitIndex = 0;

      // إخفاء النص
      for (int y = 0; y < encodedImage.height; y++) {
        for (int x = 0; x < encodedImage.width; x++) {
          if (byteIndex >= totalBytes) break;

          final pixel = encodedImage.getPixel(x, y);
          int r = pixel.r.toInt() & 0xFF;
          int g = pixel.g.toInt() & 0xFF;
          int b = pixel.b.toInt() & 0xFF;

          // الحصول على البايت الحالي (النص أو نهاية النص)
          int currentByte;
          if (byteIndex < textBytes.length) {
            currentByte = textBytes[byteIndex];
          } else {
            currentByte = 0; // نهاية النص
          }

          // إخفاء 3 بتات في هذا البكسل
          for (int channelIndex = 0; channelIndex < 3; channelIndex++) {
            if (bitIndex < 8) {
              // الحصول على البت الحالي (من اليسار إلى اليمين)
              int bit = (currentByte >> (7 - bitIndex)) & 1;

              switch (channelIndex) {
                case 0:
                  r = (r & 0xFE) | bit; // إخفاء في القناة الحمراء
                  break;
                case 1:
                  g = (g & 0xFE) | bit; // إخفاء في القناة الخضراء
                  break;
                case 2:
                  b = (b & 0xFE) | bit; // إخفاء في القناة الزرقاء
                  break;
              }

              bitIndex++;
            }
          }

          // تحديث البكسل
          encodedImage.setPixelRgb(x, y, r, g, b);

          // إذا انتهينا من هذا البايت، ننتقل إلى البايت التالي
          if (bitIndex >= 8) {
            byteIndex++;
            bitIndex = 0;
          }
        }
        if (byteIndex >= totalBytes) break;
      }

      // حفظ الصورة
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final outputPath = '${directory.path}/hidden_image_$timestamp.png';
      final outputFile = File(outputPath);

      await outputFile.writeAsBytes(img.encodePng(encodedImage));

      setState(() {
        _savedImagePath = outputPath;
        _imageDetails = {
          'hidden_text': _hiddenText,
          'hidden_date': DateTime.now().toString(),
          'saved_path': outputPath,
          'text_length': '${_hiddenText.length} حرف',
          'original_size': '${originalImage.width} x ${originalImage.height}',
          'total_bits': totalBitsNeeded,
          'total_pixels_used': totalPixelsNeeded,
        };
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم إخفاء النص "${_hiddenText}" بنجاح - ${_hiddenText.length} حرف')),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF121212),
      child: SingleChildScrollView(

        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // بطاقة عرض الصورة
            Card(
              color: Color(0xFF333333),
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'الصورة المختارة',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white),
                    ),
                    SizedBox(height: 10),
                    _selectedImage != null
                        ? Image.file(_selectedImage!, height: 200, fit: BoxFit.cover)
                        : Container(
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFF121212)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.image, size: 50, color: Colors.tealAccent),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // حقل اختيار الصورة
            Card(
              color: Colors.tealAccent,
              elevation: 4,
              child: ListTile(
                leading: Icon(Icons.photo_library,color: Colors.black,),
                title: Text('اختر صورة من المعرض',
                style: TextStyle(
                  color: Colors.black
                ),
                ),
                trailing: Icon(Icons.arrow_forward_ios,color: Colors.black,),
                onTap: _pickImage,
              ),
            ),

            SizedBox(height: 20),

            // حقل إدخال النص
            Card(
              color: Color(0xFF333333),
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'النص الذي سيتم إخفاؤه',
                      style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      style: TextStyle(color: Colors.white),
                      controller: _textController,
                      onChanged: (value) {
                        setState(() {
                          _hiddenText = value;
                        });
                      },
                      maxLines: 3,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintStyle: TextStyle(color: Colors.white),
                        hintText: 'أدخل النص الذي تريد إخفاءه في الصورة',

                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // زر إخفاء النص وحفظ الصورة
            Card(
              color: Colors.tealAccent,
              elevation: 4,
              child: ListTile(
                leading: Icon(Icons.save,color: Colors.black,),
                title: Text('إخفاء النص وحفظ الصورة',style: TextStyle(color: Colors.black),),
                subtitle: Text(_savedImagePath.isNotEmpty ? 'المسار: $_savedImagePath' : '',style: TextStyle(color: Colors.black),),
                onTap: _hideTextAndSave,
              ),
            ),

            SizedBox(height: 20),

            // بطاقة تفاصيل الصورة
            if (_imageDetails.isNotEmpty)
              Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تفاصيل الصورة',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      ..._imageDetails.entries.map((entry) =>
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Text(
                                  '${entry.key}: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Expanded(
                                  child: Text(
                                    entry.value.toString(),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          )
                      ).toList(),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}