import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionScreen extends StatefulWidget {
  const EncryptionScreen({super.key});

  @override
  State<EncryptionScreen> createState() => _EncryptionScreenState();
}

class _EncryptionScreenState extends State<EncryptionScreen> {
  String _passphrase = '';
  PlatformFile? _selectedFile;
  String _status = 'اختر ملفاً للتشفير';
  File? _encryptedFile;
  bool _isProcessing = false;

  // ========== خدمات التشفير ==========
  static final Random _rnd = Random.secure();

  static Uint8List _generateRandomBytes(int length) {
    final bytes = List<int>.generate(length, (_) => _rnd.nextInt(256));
    return Uint8List.fromList(bytes);
  }

  static List<int> _deriveKey(String password, List<int> salt, int iterations, int keyLength) {
    try {
      final passwordBytes = utf8.encode(password);

      List<int> hmacSha256(List<int> data) {
        final hmac = Hmac(sha256, passwordBytes);
        return hmac.convert(data).bytes;
      }

      final blocks = (keyLength / 32).ceil();
      final derivedKey = <int>[];

      for (int blockIndex = 1; blockIndex <= blocks; blockIndex++) {
        final block = Uint8List(4);
        block.buffer.asByteData().setUint32(0, blockIndex, Endian.big);

        final initialBlock = <int>[]..addAll(salt)..addAll(block);
        var temp = hmacSha256(initialBlock);
        final blockResult = List<int>.from(temp);

        for (int iteration = 1; iteration < iterations; iteration++) {
          temp = hmacSha256(temp);
          for (int i = 0; i < blockResult.length; i++) {
            blockResult[i] ^= temp[i];
          }
        }
        derivedKey.addAll(blockResult);
      }

      return derivedKey.sublist(0, keyLength);
    } catch (e) {
      throw Exception('فشل في اشتقاق المفتاح: $e');
    }
  }

  static Uint8List _createEncryptedFileData(Uint8List salt, Uint8List iv, Uint8List encryptedData) {
    try {
      final fileSignature = utf8.encode('FENC');
      final header = BytesBuilder();

      header.add(fileSignature);
      header.addByte(salt.length);
      header.add(salt);
      header.addByte(iv.length);
      header.add(iv);
      header.add(encryptedData);

      return header.toBytes();
    } catch (e) {
      throw Exception('فشل في إنشاء بيانات الملف المشفر: $e');
    }
  }

  Future<File> _encryptFile() async {
    try {
      const keyDerivationIterations = 100000;
      const keyLength = 32;

      Uint8List fileData;
      if (_selectedFile!.bytes != null) {
        fileData = _selectedFile!.bytes!;
      } else if (_selectedFile!.path != null) {
        final inputFile = File(_selectedFile!.path!);
        if (await inputFile.exists()) {
          fileData = await inputFile.readAsBytes();
        } else {
          throw Exception('الملف غير موجود في المسار المحدد');
        }
      } else {
        throw Exception('لا توجد بيانات ملف متاحة');
      }


      final salt = _generateRandomBytes(16);
      final iv = _generateRandomBytes(16);


      final derivedKey = _deriveKey(_passphrase, salt, keyDerivationIterations, keyLength);
      final encryptionKey = encrypt.Key(Uint8List.fromList(derivedKey));

      final encrypter = encrypt.Encrypter(encrypt.AES(encryptionKey, mode: encrypt.AESMode.cbc));
      final encrypted = encrypter.encryptBytes(fileData, iv: encrypt.IV(iv));


      final encryptedFileData = _createEncryptedFileData(salt, iv, encrypted.bytes);

      final appDir = await getApplicationDocumentsDirectory();
      final outputFile = File('${appDir.path}/encrypted_${DateTime.now().millisecondsSinceEpoch}_${_selectedFile!.name}.enc');
      await outputFile.writeAsBytes(encryptedFileData, flush: true);

      return outputFile;
    } catch (e) {
      throw Exception('فشل في عملية التشفير: ${e.toString()}');
    }
  }

  ///////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text(
            ' تشفير الملفات',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF1a1a1a),
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: _buildBody(),
        bottomNavigationBar: _buildBottomButtons(),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildPassphraseSection(),
          const SizedBox(height: 20),
          _buildFilePickerCard(),
          const SizedBox(height: 20),
          _buildStatusCard(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00B4D8), Color(0xFF0077B6)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00B4D8).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        children: [
          Icon(
            Icons.enhanced_encryption_rounded,
            size: 60,
            color: Colors.white,
          ),
          SizedBox(height: 10),
          Text(
            'تشفير آمن للملفات',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'حمِّي ملفاتك باستخدام خوارزمية AES-256 الآمنة',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassphraseSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: const Color(0xFF1a1a1a),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.password_rounded, color: Color(0xFF00B4D8)),
                SizedBox(width: 8),
                Text(
                  'كلمة المرور',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                hintText: 'أدخل كلمة مرور قوية...',
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey[800]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF00B4D8)),
                ),
                filled: true,
                fillColor: const Color(0xFF2a2a2a),
                prefixIcon: const Icon(Icons.lock_rounded, color: Color(0xFF00B4D8)),
              ),
              style: const TextStyle(color: Colors.white),
              obscureText: true,
              onChanged: (value) => _passphrase = value,
            ),
            const SizedBox(height: 8),
            const Text(
              'ملاحظة: استخدم كلمة مرور قوية ولا تفقدها، لأنك تحتاجها لفك التشفير',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePickerCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: const Color(0xFF1a1a1a),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.attach_file_rounded, color: Color(0xFF00B4D8)),
                SizedBox(width: 8),
                Text(
                  'الملف المراد تشفيره',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_selectedFile == null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.folder_open_rounded, color: Colors.white),
                  label: const Text('اختر ملف', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B4D8),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _pickFile,
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2a2a2a),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF00B4D8).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.description_rounded, color: Color(0xFF00B4D8)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedFile!.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${(_selectedFile!.size / 1024).toStringAsFixed(1)} كيلوبايت',
                            style: TextStyle(
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: const Color(0xFF1a1a1a),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info_rounded, color: Color(0xFF00B4D8)),
                SizedBox(width: 8),
                Text(
                  'حالة العملية',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getStatusColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _getStatusColor().withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  if (_isProcessing)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor()),
                      ),
                    ),
                  if (_isProcessing) const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _status,
                      style: TextStyle(
                        color: _getStatusColor(),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a1a),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: Colors.grey[800]!,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: _encryptedFile != null ? _buildAfterEncryptionButtons() : _buildEncryptionButton(),
        ),
      ),
    );
  }

  List<Widget> _buildEncryptionButton() {
    return [
      Expanded(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.lock_rounded, color: Colors.white),
          label: const Text('تشفير الملف', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00B4D8),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: _isProcessing ? null : _startEncryption,
        ),
      ),
    ];
  }

  List<Widget> _buildAfterEncryptionButtons() {
    return [
      Expanded(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.download_rounded, color: Colors.white),
          label: const Text('حفظ الملف', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: _saveEncryptedFile,
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.share_rounded, color: Colors.white),
          label: const Text('مشاركة', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00B4D8),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: _shareEncryptedFile,
        ),
      ),
    ];
  }

 /////////////////////////////////////
  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = result.files.single;
          _status = ' تم اختيار الملف: ${_selectedFile!.name}';
          _encryptedFile = null;
        });
      }
    } catch (e) {
      _showMessage('خطأ', 'فشل في اختيار الملف: $e');
    }
  }

  Future<void> _startEncryption() async {
    if (_selectedFile == null) {
      _showMessage('تحذير', 'يرجى اختيار ملف أولاً');
      return;
    }
    if (_passphrase.isEmpty) {
      _showMessage('تحذير', 'يرجى إدخال كلمة المرور');
      return;
    }

    setState(() {
      _isProcessing = true;
      _status = '🔐 جارِ تشفير الملف...';
    });

    try {
      _encryptedFile = await _encryptFile();

      setState(() {
        _status = '✅ تم التشفير بنجاح!\nالملف: ${_encryptedFile!.path.split('/').last}';
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _status = '❌ فشل التشفير: ${e.toString()}';
        _isProcessing = false;
      });
    }
  }

  Future<void> _saveEncryptedFile() async {
    if (_encryptedFile == null) return;

    try {
      final downloadsDir = await getDownloadsDirectory();
      if (downloadsDir != null) {
        final fileName = _encryptedFile!.path.split('/').last;
        final savedFile = File('${downloadsDir.path}/$fileName');
        await savedFile.writeAsBytes(await _encryptedFile!.readAsBytes());
        _showMessage('نجاح', 'تم حفظ الملف في مجلد التنزيلات');
      }
    } catch (e) {
      _showMessage('خطأ', 'فشل حفظ الملف: $e');
    }
  }

  Future<void> _shareEncryptedFile() async {
    if (_encryptedFile != null) {
      try {
        final xfile = XFile(_encryptedFile!.path);
        await Share.shareXFiles([xfile], text: 'ملف مشفر - تطبيق التشفير الآمن');
      } catch (e) {
        _showMessage('خطأ', 'فشل المشاركة: $e');
      }
    }
  }

  Color _getStatusColor() {
    if (_isProcessing) return const Color(0xFFFF9800);
    if (_status.contains('تم') || _status.contains('نجاح')) return const Color(0xFF4CAF50);
    if (_status.contains('فشل') || _status.contains('خطأ')) return const Color(0xFFF44336);
    return Colors.grey[400]!;
  }

  void _showMessage(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a1a),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Text(
            message,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'حسناً',
              style: TextStyle(color: Color(0xFF00B4D8)),
            ),
          ),
        ],
      ),
    );
  }
}