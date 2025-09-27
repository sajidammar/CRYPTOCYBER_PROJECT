import 'dart:convert';
import 'dart:math' as math;

import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';


class FileAnalysisTab extends StatefulWidget {
  const FileAnalysisTab({super.key});

  @override
  _FileAnalysisTabState createState() => _FileAnalysisTabState();
}

class _FileAnalysisTabState extends State<FileAnalysisTab> {
  String _analysisResult = 'لم يتم تحليل أي ملف بعد';
  bool _isAnalyzing = false;
  PlatformFile? _selectedFile;

  Future<void> _pickAndAnalyzeFile() async {
    try {
      FilePickerResult? result;
      result = await FilePicker.platform.pickFiles();

      if (result != null && result.files.isNotEmpty) {
        PlatformFile selectedFile = result.files.first;

        setState(() {
          _selectedFile = selectedFile;
          _isAnalyzing = true;
          _analysisResult = 'جاري تحليل الملف...';
        });

        await Future.delayed(Duration(milliseconds: 500));

        String analysisResult = await _analyzeFile(selectedFile);

        setState(() {
          _analysisResult = analysisResult;
          _isAnalyzing = false;
        });
      } else {
        setState(() {
          _analysisResult = 'لم يتم اختيار أي ملف للتحليل';
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      setState(() {
        _analysisResult = 'خطأ في تحليل الملف: $e';
        _isAnalyzing = false;
      });
    }
  }

  Future<String> _analyzeFile(PlatformFile file) async {
    String result = '════════ تحليل الملف ════════\n\n';
    result += '📁 اسم الملف: ${file.name}\n';
    result += '📊 حجم الملف: ${_formatFileSize(file.size)}\n';
    result += '🔤 الامتداد: ${file.extension ?? 'غير معروف'}\n\n';

    result += '🔐 تحليل التجزئة:\n';
    result += '────────────────────\n';

    if (file.bytes != null) {
      result += 'MD5: ${_calculateMD5(file.bytes!)}\n';
      result += 'SHA-1: ${_calculateSHA1(file.bytes!)}\n';
      result += 'SHA-256: ${_calculateSHA256(file.bytes!)}\n\n';
    } else {
      result += '⚠️ لا يمكن تحليل التجزئة - بيانات الملف غير متوفرة\n\n';
    }

    result += '📄 تحليل المحتوى:\n';
    result += '────────────────────\n';

    if (file.bytes != null) {
      result += _analyzeFileContent(file.bytes!, file.extension ?? '');
    } else {
      result += '⚠️ لا يمكن تحليل المحتوى - بيانات الملف غير متوفرة\n';
    }

    result += '\n🔒 تحليل التشفير:\n';
    result += '────────────────────\n';
    result += _analyzeEncryption(file.bytes);

    return result;
  }

  String _calculateMD5(List<int> bytes) {
    return md5.convert(bytes).toString();
  }

  String _calculateSHA1(List<int> bytes) {
    return sha1.convert(bytes).toString();
  }

  String _calculateSHA256(List<int> bytes) {
    return sha256.convert(bytes).toString();
  }

  String _analyzeFileContent(List<int> bytes, String extension) {
    String analysis = '';

    try {
      String content = utf8.decode(bytes, allowMalformed: true);
      if (content.length > 500) {
        content = content.substring(0, 500) + '...';
      }

      analysis += 'النص المقروء: ${content.length} حرف\n';
      analysis += 'العينات: ${content.replaceAll('\n', ' ')}\n\n';
    } catch (e) {
      analysis += 'الملف غير نصي أو مشفر\n\n';
    }

    analysis += '🎯 نوع الملف المحتمل:\n';
    switch (extension.toLowerCase()) {
      case 'txt': analysis += 'ملف نصي عادي'; break;
      case 'pdf': analysis += 'ملف PDF'; break;
      case 'jpg': case 'jpeg': case 'png': case 'gif':
      analysis += 'ملف صورة'; break;
      case 'zip': case 'rar': case '7z':
      analysis += 'ملف مضغوط'; break;
      case 'exe': case 'dll': case 'msi':
      analysis += 'ملف تنفيذي'; break;
      default: analysis += 'غير معروف'; break;
    }

    return analysis;
  }

  String _analyzeEncryption(List<int>? bytes) {
    if (bytes == null || bytes.isEmpty) return 'لا يمكن تحليل التشفير - بيانات فارغة\n';

    String analysis = '';

    if (bytes.length >= 8) {
      List<int> header = bytes.sublist(0, math.min(8, bytes.length));
      String headerHex = header.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');

      analysis += 'رأس الملف (hex): $headerHex\n';

      if (headerHex.contains('53 51 4c 69 74 65')) {
        analysis += '🛡️ محتمل: قاعدة بيانات SQLite\n';
      } else if (headerHex.contains('50 4b 03 04')) {
        analysis += '📦 محتمل: ملف ZIP\n';
      } else if (headerHex.contains('25 50 44 46')) {
        analysis += '📄 محتمل: ملف PDF\n';
      } else {
        analysis += '❓ نمط غير معروف - قد يكون مشفراً\n';
      }
    }

    double entropy = _calculateEntropy(bytes);
    analysis += '📊 الانتروبي: ${entropy.toStringAsFixed(2)}\n';
    analysis += entropy > 7.5 ? '🔐 محتمل: ملف مشفر (انتروبي عالي)\n' : '📖 محتمل: ملف غير مشفر (انتروبي منخفض)\n';

    return analysis;
  }

  double _calculateEntropy(List<int> bytes) {
    if (bytes.isEmpty) return 0.0;

    Map<int, int> frequency = {};
    for (int byte in bytes) {
      frequency[byte] = (frequency[byte] ?? 0) + 1;
    }

    double entropy = 0.0;
    for (int count in frequency.values) {
      double probability = count / bytes.length;
      entropy -= probability * math.log(probability) / math.ln2;
    }

    return entropy;
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
                    Icons.cloud_upload,
                    size: 50,
                    color: Color(0xFFe94560),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'ارفع ملف للتحليل',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: _isAnalyzing ? null : _pickAndAnalyzeFile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFe94560),
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
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
                        : Text('اختر ملف'),
                  ),
                  if (_selectedFile != null) ...[
                    SizedBox(height: 10),
                    Text(
                      'الملف المحدد: ${_selectedFile!.name}',
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