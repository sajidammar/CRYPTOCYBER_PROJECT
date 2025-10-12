import 'dart:convert';
import 'dart:math' as math;
import 'trasilation_file_class.dart';
import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class FileAnalysisTab extends StatefulWidget {
  const FileAnalysisTab({super.key});

  @override
  _FileAnalysisTabState createState() => _FileAnalysisTabState();
}

class _FileAnalysisTabState extends State<FileAnalysisTab> {
  String _analysisResult = 'No file analyzed yet';
  bool _isAnalyzing = false;
  PlatformFile? _selectedFile;

  // الامتدادات المدعومة (لا تشمل الصور)
  final Set<String> _supportedExtensions = {
    'txt', 'pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx',
    'zip', 'rar', '7z', 'tar', 'gz',
    'exe', 'dll', 'msi', 'apk',
    'html', 'htm', 'css', 'js', 'json', 'xml',
    'mp3', 'wav', 'mp4', 'avi', 'mkv',
    'sql', 'db', 'sqlite',
    'py', 'java', 'cpp', 'c', 'cs', 'php', 'rb'
  };

  // فئات الملفات
  final Map<String, String> _fileCategories = {
    'txt': 'Text Document',
    'pdf': 'PDF Document',
    'doc': 'Word Document',
    'docx': 'Word Document',
    'xls': 'Excel Spreadsheet',
    'xlsx': 'Excel Spreadsheet',
    'ppt': 'PowerPoint Presentation',
    'pptx': 'PowerPoint Presentation',
    'zip': 'Compressed Archive',
    'rar': 'Compressed Archive',
    '7z': 'Compressed Archive',
    'tar': 'Compressed Archive',
    'gz': 'Compressed Archive',
    'exe': 'Executable File',
    'dll': 'Dynamic Library',
    'msi': 'Windows Installer',
    'apk': 'Android Application',
    'html': 'Web Page',
    'htm': 'Web Page',
    'css': 'Stylesheet',
    'js': 'JavaScript File',
    'json': 'JSON Data',
    'xml': 'XML Data',
    'mp3': 'Audio File',
    'wav': 'Audio File',
    'mp4': 'Video File',
    'avi': 'Video File',
    'mkv': 'Video File',
    'sql': 'SQL Script',
    'db': 'Database File',
    'sqlite': 'Database File',
    'py': 'Python Script',
    'java': 'Java Source',
    'cpp': 'C++ Source',
    'c': 'C Source',
    'cs': 'C# Source',
    'php': 'PHP Script',
    'rb': 'Ruby Script'
  };

  Future<void> _pickAndAnalyzeFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile selectedFile = result.files.first;

        // التحقق إذا كان الملف صورة
        if (_isImageFile(selectedFile.extension)) {
          setState(() {
            _analysisResult = 'This file type is not supported for analysis\n\n'
                'Please use the "Image Analysis" tab for image files.\n'
                'Please select a different file type';
            _isAnalyzing = false;
          });
          return;
        }

        setState(() {
          _selectedFile = selectedFile;
          _isAnalyzing = true;
          _analysisResult = 'Analyzing file...';
        });

        await Future.delayed(Duration(milliseconds: 500));

        String analysisResult = await _analyzeFile(selectedFile);

        setState(() {
          _analysisResult = analysisResult;
          _isAnalyzing = false;
        });
      } else {
        setState(() {
          _analysisResult = 'No file selected for analysis';
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      setState(() {
        _analysisResult = 'Error analyzing file: $e';
        _isAnalyzing = false;
      });
    }
  }

  bool _isImageFile(String? extension) {
    if (extension == null) return false;
    final imageExtensions = {'jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'tiff', 'ico', 'svg'};
    return imageExtensions.contains(extension.toLowerCase());
  }

  Future<String> _analyzeFile(PlatformFile file) async {
    String result = '════════ File Analysis ════════\n\n';

    result += '📁 Basic Information:\n';
    result += '────────────────────\n';
    result += '📁 File Name: ${file.name}\n';
    result += '📊 File Size: ${_formatFileSize(file.size)}\n';
    result += '🔤 Extension: ${file.extension ?? 'Unknown'}\n';
    result += '📄 File Type: ${_getFileType(file.extension)}\n\n';

    result += '🔐 Hash Analysis:\n';
    result += '────────────────────\n';

    if (file.bytes != null) {
      result += 'MD5: ${_calculateMD5(file.bytes!)}\n';
      result += 'SHA-1: ${_calculateSHA1(file.bytes!)}\n';
      result += 'SHA-256: ${_calculateSHA256(file.bytes!)}\n\n';
    } else {
      result += '⚠️ Cannot analyze hash - file data unavailable\n\n';
    }

    result += '📄 Content Analysis:\n';
    result += '────────────────────\n';
    result += _analyzeFileContent(file.bytes, file.extension ?? '');

    result += '\n🔒 Encryption & Security Analysis:\n';
    result += '────────────────────\n';
    result += _analyzeEncryptionAndSecurity(file.bytes, file.extension ?? '');

    return result;
  }

  String _getFileType(String? extension) {
    if (extension == null) return 'Unknown file type';
    return _fileCategories[extension.toLowerCase()] ?? 'Unknown file type';
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

  String _analyzeFileContent(List<int>? bytes, String extension) {
    if (bytes == null) return '⚠️ Cannot analyze content - file data unavailable\n\n';

    String analysis = '';

    // محاولة القراءة كنص للملفات النصية
    if (_isTextBasedFile(extension)) {
      try {
        String content = utf8.decode(bytes, allowMalformed: true);
        if (content.length > 500) {
          content = content.substring(0, 500) + '...';
        }

        analysis += 'Readable text: ${content.length} characters\n';
        analysis += 'Samples: ${content.replaceAll('\n', ' ')}\n\n';
      } catch (e) {
        analysis += 'File is not text-based or encrypted\n\n';
      }
    } else {
      analysis += 'Binary file - content analysis limited\n\n';
    }

    // تحليل توقيع الملف
    analysis += '🔍 File Signature Analysis:\n';
    analysis += _analyzeFileSignature(bytes, extension);

    return analysis;
  }

  bool _isTextBasedFile(String extension) {
    final textExtensions = {'txt', 'html', 'htm', 'css', 'js', 'json', 'xml', 'csv', 'log', 'md'};
    return textExtensions.contains(extension.toLowerCase());
  }

  String _analyzeFileSignature(List<int> bytes, String extension) {
    if (bytes.length < 8) return '  File too small for signature analysis\n';

    String analysis = '';
    List<int> header = bytes.sublist(0, math.min(16, bytes.length));
    String headerHex = header.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');

    analysis += '  File header (hex): $headerHex\n';

    // التواقيع الشائعة للملفات
    if (headerHex.startsWith('25 50 44 46')) {
      analysis += '  ✅ PDF document (confirmed by signature)\n';
    } else if (headerHex.startsWith('50 4b 03 04') || headerHex.startsWith('50 4b 05 06') || headerHex.startsWith('50 4b 07 08')) {
      analysis += '  ✅ ZIP archive (confirmed by signature)\n';
    } else if (headerHex.startsWith('52 61 72 21 1a 07 00')) {
      analysis += '  ✅ RAR archive (confirmed by signature)\n';
    } else if (headerHex.startsWith('37 7a bc af 27 1c')) {
      analysis += '  ✅ 7-Zip archive (confirmed by signature)\n';
    } else if (headerHex.startsWith('d0 cf 11 e0 a1 b1 1a e1')) {
      analysis += '  ✅ Microsoft Office document\n';
    } else if (headerHex.startsWith('4d 5a')) {
      analysis += '  ✅ Windows executable (EXE/DLL)\n';
    } else if (bytes.length >= 2 && bytes[0] == 0x23 && bytes[1] == 0x21) {
      analysis += '  ✅ Script file (shebang detected)\n';
    } else {
      analysis += '  ⚠️ Unknown file signature\n';
    }

    return analysis;
  }

  String _analyzeEncryptionAndSecurity(List<int>? bytes, String extension) {
    if (bytes == null || bytes.isEmpty) return 'Cannot analyze encryption - empty data\n';

    String analysis = '';

    // تحليل الانتروبي
    double entropy = _calculateEntropy(bytes);
    analysis += '📊 Entropy: ${entropy.toStringAsFixed(2)}\n';
    if (entropy > 7.5) {
      analysis += '🔐 High entropy - Possibly encrypted or compressed\n';
    } else if (entropy > 6.0) {
      analysis += '📖 Medium entropy - Mixed content\n';
    } else {
      analysis += '📝 Low entropy - Likely plain text or structured data\n';
    }

    // تقييم المخاطر
    analysis += '\n⚠️ Risk Assessment:\n';
    analysis += _assessRisk(extension, entropy);

    // فحص سلامة الملف
    analysis += '\n🛡️ File Integrity:\n';
    analysis += _checkFileIntegrity(bytes, extension);

    return analysis;
  }

  String _assessRisk(String extension, double entropy) {
    final highRiskExtensions = {'exe', 'dll', 'msi', 'apk', 'bat', 'cmd', 'ps1', 'scr'};
    final mediumRiskExtensions = {'zip', 'rar', '7z', 'jar', 'iso'};

    if (highRiskExtensions.contains(extension.toLowerCase())) {
      return '  Medium risk - Executable file\n';
    } else if (mediumRiskExtensions.contains(extension.toLowerCase())) {
      return '  Low risk - Archive file\n';
    } else if (entropy > 7.8 && !_isTextBasedFile(extension)) {
      return '  High risk - Unknown or suspicious file\n';
    } else {
      return '  Low risk - Normal file\n';
    }
  }

  String _checkFileIntegrity(List<int> bytes, String extension) {
    // فحوصات السلامة الأساسية بناءً على نوع الملف
    if (bytes.isEmpty) return '  ❌ Empty file\n';

    if (extension.toLowerCase() == 'pdf' && bytes.length > 4) {
      String start = String.fromCharCodes(bytes.sublist(0, 4));
      String end = String.fromCharCodes(bytes.sublist(bytes.length - 6));
      if (start == '%PDF' && end.contains('%%EOF')) {
        return '  ✅ File appears to be valid\n';
      } else {
        return '  ⚠️ Potential file corruption detected\n';
      }
    }

    if ((extension.toLowerCase() == 'zip' || extension.toLowerCase() == 'jar') && bytes.length > 4) {
      String start = bytes.sublist(0, 2).map((b) => b.toRadixString(16)).join('');
      if (start == '504b') {
        return '  ✅ File appears to be valid\n';
      } else {
        return '  ⚠️ Potential file corruption detected\n';
      }
    }

    return '  ✅ Basic integrity check passed\n';
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
      padding: EdgeInsets.all(16),
      color: Color(0xFF121212),
      child: Column(
        children: [
          // بطاقة رفع الملف
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
                      Icons.insert_drive_file,
                      size: 30,
                      color: Colors.tealAccent,
                    ),
                  ),
                  SizedBox(height: 16),
                  TranslatedText(
                    englishText: 'Upload File for Analysis',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  TranslatedText(
                    englishText: 'Select any file except images for analysis',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFB0B0B0),
                    ),
                    align: TextAlign.center,
                  ),
                  SizedBox(height: 4),
                  TranslatedText(
                    englishText: 'Supported: Documents, Archives, Executables, Media, Code',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF808080),
                    ),
                    align: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _isAnalyzing ? null : _pickAndAnalyzeFile,
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
                            TranslatedText(englishText: 'Upload File'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_selectedFile != null) ...[
                    SizedBox(height: 16),
                    Container(
                      width: double.infinity, // إصلاح التدفق
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
                          Expanded( // إصلاح التدفق
                            child: TranslatedText(
                              englishText: 'Selected file: ${_selectedFile!.name}',
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

          // حاوية النتائج
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
