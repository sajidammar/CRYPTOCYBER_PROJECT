import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class DecryptionScreen extends StatefulWidget {
  const DecryptionScreen({super.key});

  @override
  State<DecryptionScreen> createState() => _DecryptionScreenState();
}

class _DecryptionScreenState extends State<DecryptionScreen> {
  String _passphrase = '';
  PlatformFile? _selectedFile;
  String _status = 'اختر ملفاً مشفراً';
  File? _decryptedFile;
  bool _isProcessing = false;

  //////////////////////////////////////
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

  Future<File> _decryptFile() async {
    try {
      const keyDerivationIterations = 100000;
      const keyLength = 32;


      Uint8List encryptedFileData;
      if (_selectedFile!.bytes != null) {
        encryptedFileData = _selectedFile!.bytes!;
      } else if (_selectedFile!.path != null) {
        final inputFile = File(_selectedFile!.path!);
        if (await inputFile.exists()) {
          encryptedFileData = await inputFile.readAsBytes();
        } else {
          throw Exception('الملف غير موجود في المسار المحدد');
        }
      } else {
        throw Exception('لا توجد بيانات ملف متاحة');
      }


      final data = ByteData.sublistView(encryptedFileData);
      int offset = 0;


      final signature = utf8.decode(encryptedFileData.sublist(offset, offset + 4));
      if (signature != 'FENC') {
        throw Exception('توقيع الملف غير صحيح - قد يكون الملف تالفاً');
      }
      offset += 4;


      final saltLength = data.getUint8(offset);
      offset += 1;
      final salt = encryptedFileData.sublist(offset, offset + saltLength);
      offset += saltLength;


      final ivLength = data.getUint8(offset);
      offset += 1;
      final iv = encryptedFileData.sublist(offset, offset + ivLength);
      offset += ivLength;


      final encryptedData = encryptedFileData.sublist(offset);


      final derivedKey = _deriveKey(_passphrase, salt, keyDerivationIterations, keyLength);
      final decryptionKey = encrypt.Key(Uint8List.fromList(derivedKey));


      final decrypter = encrypt.Encrypter(encrypt.AES(decryptionKey, mode: encrypt.AESMode.cbc));
      final decrypted = decrypter.decryptBytes(encrypt.Encrypted(encryptedData), iv: encrypt.IV(iv));


      final appDir = await getApplicationDocumentsDirectory();
      final originalName = _selectedFile!.name.replaceAll('.enc', '');
      final outputFile = File('${appDir.path}/decrypted_${DateTime.now().millisecondsSinceEpoch}_$originalName');
      await outputFile.writeAsBytes(decrypted, flush: true);

      return outputFile;
    } catch (e) {
      throw Exception('فشل في عملية فك التشفير: ${e.toString()}');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.black,
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
          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        children: [
          Icon(
            Icons.lock_open_rounded,
            size: 60,
            color: Colors.white,
          ),
          SizedBox(height: 10),
          Text(
            'فك تشفير الملفات',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'استرجع ملفاتك المشفرة إلى وضعها الأصلي',
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
                Icon(Icons.password_rounded, color: Color(0xFF4CAF50)),
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
                hintText: 'أدخل كلمة المرور المستخدمة في التشفير...',
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey[800]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF4CAF50)),
                ),
                filled: true,
                fillColor: const Color(0xFF2a2a2a),
                prefixIcon: const Icon(Icons.lock_rounded, color: Color(0xFF4CAF50)),
              ),
              style: const TextStyle(color: Colors.white),
              obscureText: true,
              onChanged: (value) => _passphrase = value,
            ),
            const SizedBox(height: 8),
            const Text(
              'ملاحظة: يجب استخدام نفس كلمة المرور التي استخدمتها في التشفير',
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
                Icon(Icons.attach_file_rounded, color: Color(0xFF4CAF50)),
                SizedBox(width: 8),
                Text(
                  'الملف المشفر',
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
                  label: const Text('اختر ملف مشفر', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
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
                  border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.description_rounded, color: Color(0xFF4CAF50)),
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
                Icon(Icons.info_rounded, color: Color(0xFF4CAF50)),
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
          children: _decryptedFile != null ? _buildAfterDecryptionButtons() : _buildDecryptionButton(),
        ),
      ),
    );
  }

  List<Widget> _buildDecryptionButton() {
    return [
      Expanded(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.lock_open_rounded, color: Colors.white),
          label: const Text('فك التشفير', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: _isProcessing ? null : _startDecryption,
        ),
      ),
    ];
  }

  List<Widget> _buildAfterDecryptionButtons() {
    return [
      Expanded(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.download_rounded, color: Colors.white),
          label: const Text('حفظ الملف', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00B4D8),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: _saveDecryptedFile,
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.share_rounded, color: Colors.white),
          label: const Text('مشاركة', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: _shareDecryptedFile,
        ),
      ),
    ];
  }

  // ========== دوال فك التشفير ==========
  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = result.files.single;
          _status = '📁 تم اختيار الملف: ${_selectedFile!.name}';
          _decryptedFile = null;
        });
      }
    } catch (e) {
      _showMessage('خطأ', 'فشل في اختيار الملف: $e');
    }
  }

  Future<void> _startDecryption() async {
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
      _status = '🔓 جارِ فك تشفير الملف...';
    });

    try {
      _decryptedFile = await _decryptFile();

      setState(() {
        _status = '✅ تم فك التشفير بنجاح!\nالملف: ${_decryptedFile!.path.split('/').last}';
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _status = '❌ فشل فك التشفير: ${e.toString()}';
        _isProcessing = false;
      });
    }
  }

  Future<void> _saveDecryptedFile() async {
    if (_decryptedFile == null) return;

    try {
      final downloadsDir = await getDownloadsDirectory();
      if (downloadsDir != null) {
        final fileName = _decryptedFile!.path.split('/').last;
        final savedFile = File('${downloadsDir.path}/$fileName');
        await savedFile.writeAsBytes(await _decryptedFile!.readAsBytes());
        _showMessage('نجاح', 'تم حفظ الملف في مجلد التنزيلات');
      }
    } catch (e) {
      _showMessage('خطأ', 'فشل حفظ الملف: $e');
    }
  }

  Future<void> _shareDecryptedFile() async {
    if (_decryptedFile != null) {
      try {
        final xfile = XFile(_decryptedFile!.path);
        await Share.shareXFiles([xfile], text: 'ملف مفكوك - تطبيق التشفير الآمن');
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
              style: TextStyle(color: Color(0xFF4CAF50)),
            ),
          ),
        ],
      ),
    );
  }
}