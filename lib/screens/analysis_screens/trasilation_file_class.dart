
import 'package:flutter/material.dart';

// كلاس منفصل للترجمة والتوضيحات
class FileAnalysisTranslations {
  static final Map<String, String> _translations = {
    'File Analysis': 'تحليل الملف - فحص شامل للملفات بأنواعها المختلفة',
    'Upload File for Analysis': 'رفع ملف للتحليل - تحميل ملف لفحصه وتحليله',
    'Select any file except images for analysis': 'اختر أي ملف ما عدا الصور للتحليل - يدعم جميع أنواع الملفات ماعدا الصور',
    'Supported: Documents, Archives, Executables, Media, Code': 'الملفات المدعومة: المستندات، الأرشيفات، الملفات التنفيذية، الوسائط، الأكواد',
    'Upload File': 'رفع ملف - تحميل الملف المطلوب',
    'Analysis Results': 'نتائج التحليل - خلاصة الفحص والتحليل',
    'Basic Information': 'المعلومات الأساسية - البيانات الرئيسية عن الملف',
    'File Name': 'اسم الملف - التسمية الأصلية للملف',
    'File Size': 'حجم الملف - المساحة التي يشغلها على القرص',
    'Extension': 'الامتداد - نوع الملف بناءً على امتداده',
    'File Type': 'نوع الملف - التصنيف الرئيسي للملف',
    'Hash Analysis': 'تحليل التجزئة - إنشاء بصمات رقمية فريدة للملف',
    'Content Analysis': 'تحليل المحتوى - فحص البيانات داخل الملف',
    'Encryption Analysis': 'تحليل التشفير - فحص درجة الحماية والتشفير',
    'Security Analysis': 'تحليل الأمان - تقييم مستوى الأمان والمخاطر',
    'Readable text': 'النص المقروء - البيانات النصية المستخرجة من الملف',
    'characters': 'حرف - عدد الرموز النصية في الملف',
    'Samples': 'العينات - جزء من المحتوى لعرضه',
    'File header (hex)': 'رأس الملف (hex) - البايتات الأولى التي تحدد نوع الملف',
    'Entropy': 'الانتروبي - مقياس العشوائية في بيانات الملف',
    'File Signature': 'توقيع الملف - النمط الثابت الذي يحدد نوع الملف',
    'Risk Level': 'مستوى الخطورة - تقييم المخاطر المحتملة',
    'File Integrity': 'سلامة الملف - فحص سلامة وهيكل الملف',
    'Low risk - Normal file': 'خطورة منخفضة - ملف عادي وآمن',
    'Medium risk - Executable file': 'خطورة متوسطة - ملف تنفيذي يتطلب حذراً',
    'High risk - Unknown or suspicious file': 'خطورة عالية - ملف مجهول أو مشبوه',
    'Text Document': 'مستند نصي - ملف يحتوي على نص عادي',
    'PDF Document': 'مستند PDF - ملف بصيغة المستندات المحمولة',
    'Word Document': 'مستند Word - ملف معالجة النصوص من مايكروسوفت',
    'Excel Spreadsheet': 'جدول بيانات Excel - ملف جداول البيانات',
    'PowerPoint Presentation': 'عرض تقديمي - ملف عروض PowerPoint',
    'Compressed Archive': 'أرشيف مضغوط - ملف يحتوي على ملفات مضغوطة',
    'Executable File': 'ملف تنفيذي - برنامج أو تطبيق قابل للتشغيل',
    'Dynamic Library': 'مكتبة ديناميكية - ملف مساند للبرامج',
    'Windows Installer': 'مثبت Windows - برنامج تثبيت للتطبيقات',
    'Android Application': 'تطبيق أندرويد - تطبيق للأجهزة الذكية',
    'Web Page': 'صفحة ويب - ملف HTML لتصفح الإنترنت',
    'Stylesheet': 'ملف تنسيق - CSS لتنسيق صفحات الويب',
    'JavaScript File': 'ملف JavaScript - كود برمجة للويب',
    'JSON Data': 'بيانات JSON - تنسيق لتبادل البيانات',
    'XML Data': 'بيانات XML - لغة التوصيف القابلة للتمديد',
    'Audio File': 'ملف صوتي - تسجيلات صوتية وموسيقى',
    'Video File': 'ملف فيديو - تسجيلات فيديو وأفلام',
    'SQL Script': 'نص SQL - أوامر قواعد البيانات',
    'Database File': 'ملف قاعدة بيانات - يحتوي على بيانات منظمة',
    'Python Script': 'نص Python - كود برمجة بلغة Python',
    'Java Source': 'كود Java - كود برمجة بلغة Java',
    'C++ Source': 'كود C++ - كود برمجة بلغة C++',
    'C Source': 'كود C - كود برمجة بلغة C',
    'C# Source': 'كود C# - كود برمجة بلغة C#',
    'PHP Script': 'نص PHP - كود برمجة للويب',
    'Ruby Script': 'نص Ruby - كود برمجة بلغة Ruby',
    'Analyzing file...': 'جاري تحليل الملف... - عملية الفحص قيد التنفيذ',
    'No file analyzed yet': 'لم يتم تحليل أي ملف بعد - لم يتم اختيار أي ملف للتحليل',
    'No file selected for analysis': 'لم يتم اختيار أي ملف للتحليل - يرجى اختيار ملف',
    'Error analyzing file': 'خطأ في تحليل الملف - حدث مشكلة أثناء التحليل',
    'Selected file': 'الملف المحدد - الملف الذي تم اختياره للتحليل',
    'Cannot analyze hash - file data unavailable': 'لا يمكن تحليل التجزئة - بيانات الملف غير متوفرة',
    'Cannot analyze content - file data unavailable': 'لا يمكن تحليل المحتوى - بيانات الملف غير متوفرة',
    'Cannot analyze encryption - empty data': 'لا يمكن تحليل التشفير - بيانات فارغة',
    'File is not text-based or encrypted': 'الملف غير نصي أو مشفر - لا يمكن قراءة محتواه',
    'Unknown file type': 'نوع ملف غير معروف - لا يمكن التعرف على نوعه',
    'File appears to be valid': 'الملف يبدو سليماً - لا توجد مشاكل ظاهرية',
    'Potential file corruption detected': 'تم اكتشاف تلف محتمل في الملف -可能存在文件损坏',
    'This file type is not supported for analysis': 'نوع الملف هذا غير مدعوم للتحليل - يرجى استخدام تبويب تحليل الصور',
    'Please select a different file type': 'يرجى اختيار نوع ملف مختلف - الملفات النصية والمضغوطة والتنفيذية مدعومة',
    'Binary file - content analysis limited': 'ملف ثنائي - التحليل محدود للمحتوى النصي',
    'File too small for signature analysis': 'الملف صغير جداً لتحليل التوقيع',
    'High entropy - Possibly encrypted or compressed': 'انتروبي عالي -可能加密或压缩',
    'Medium entropy - Mixed content': 'انتروبي متوسط - محتوى مختلط',
    'Low entropy - Likely plain text or structured data': 'انتروبي منخفض -很可能为纯文本或结构化数据',
    'Basic integrity check passed': 'تم اجتياز فحص السلامة الأساسي',
    'Empty file': 'ملف فارغ - لا يحتوي على بيانات'
  };

  static String getTranslation(String englishText) {
    return _translations[englishText] ?? englishText;
  }
}

// ويدجت منفصل للنص المترجم مع إصلاح مشكلة التولتِب
class TranslatedText extends StatelessWidget {
  final String englishText;
  final TextStyle? style;
  final TextAlign? align;

  const TranslatedText({
    Key? key,
    required this.englishText,
    this.style,
    this.align,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: FileAnalysisTranslations.getTranslation(englishText),
      waitDuration: Duration(milliseconds: 300),
      showDuration: Duration(seconds: 5),
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.tealAccent, width: 1),
      ),
      textStyle: TextStyle(
        color: Colors.white,
        fontSize: 14,
        height: 1.4,
        fontFamily: 'Cairo',
      ),
      preferBelow: false,
      verticalOffset: 10,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Text(
          englishText,
          style: style,
          textAlign: align,
        ),
      ),
    );
  }
}