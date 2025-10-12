
import 'package:flutter/material.dart';

// Translation class for Image Analysis
class ImageAnalysisTranslations {
  static final Map<String, String> _translations = {
    'Upload Image for Analysis': 'رفع صورة للتحليل - تحميل صورة لفحصها وتحليلها',
    'Select an image from gallery to analyze': 'اختر صورة من معرض الصور لتحليلها - يدعم جميع أنواع الصور',
    'Upload Image': 'رفع صورة - تحميل الصورة المطلوبة',
    'Analysis Results': 'نتائج التحليل - خلاصة الفحص والتحليل',
    'Basic Information': 'المعلومات الأساسية - البيانات الرئيسية عن الصورة',
    'Pixel Analysis': 'تحليل البكسلات - فحص بيانات البكسل واللون',
    'EXIF Data': 'بيانات EXIF - المعلومات الوصفية المخزنة في الصورة',
    'Hash Analysis': 'تحليل التجزئة - إنشاء بصمات رقمية فريدة للصورة',
    'Hidden Data Analysis': 'تحليل البيانات المخفية - البحث عن معلومات مخبأة',
    'Image Analysis': 'تحليل الصورة - فحص شامل للصور بأنواعها',
    'Path': 'المسار - موقع الملف على الجهاز',
    'Size': 'الحجم - المساحة التي تشغلها الصورة',
    'Dimensions': 'الأبعاد - عرض وارتفاع الصورة بالبكسل',
    'Channels': 'القنوات - عدد قنوات الألوان في الصورة',
    'Format': 'التنسيق - نوع وخصائص ترميز الصورة',
    'Color Analysis': 'تحليل الألوان - فحص خصائص الألوان في الصورة',
    'Depth': 'العمق - عدد البتات المستخدمة لكل لون',
    'Transparency': 'الشفافية - وجود قناة ألفا للشفافية',
    'Pixel Samples': 'عينات البكسل - أمثلة من ألوان البكسلات',
    'Cannot decode image': 'لا يمكن فك تشفير الصورة - تلف أو تنسيق غير مدعوم',
    'Error analyzing image': 'خطأ في تحليل الصورة - مشكلة تقنية أثناء التحليل',
    'No EXIF data found': 'لا توجد بيانات EXIF - الصورة لا تحتوي على بيانات وصفية',
    'No readable EXIF data': 'لا توجد بيانات EXIF قابلة للقراءة - بيانات تالفة أو مشفرة',
    'Cannot read EXIF data': 'لا يمكن قراءة بيانات EXIF - مشكلة في الوصول للبيانات',
    'Image Description': 'وصف الصورة - النص الوصفي المخزن في الصورة',
    'Manufacturer': 'الشركة المصنعة - شركة تصنيع الكاميرا',
    'Camera Model': 'موديل الكاميرا - نوع الجهاز المستخدم للتصوير',
    'Capture Date': 'تاريخ الالتقاط - وقت التقاط الصورة',
    'Location Data': 'بيانات الموقع - إحداثيات GPS للصورة',
    'LSB Ratio': 'نسبة LSB - مقياس للبيانات المخفية في البتات الأقل أهمية',
    'Unusual activity - may contain hidden data': 'نشاط غير عادي - قد تحتوي على بيانات مخفية',
    'Normal ratio - no obvious hidden data': 'نسبة طبيعية - لا توجد بيانات مخفية واضحة',
    'End Bytes': 'البايتات النهائية - آخر بايتات في ملف الصورة',
    'May contain additional data': 'قد تحتوي على بيانات إضافية - معلومات زائدة عن نهاية الملف',
    'No image analyzed yet': 'لم يتم تحليل أي صورة بعد - لم يتم اختيار أي صورة للتحليل',
    'No image selected for analysis': 'لم يتم اختيار أي صورة للتحليل - يرجى اختيار صورة',
    'Error selecting image': 'خطأ في اختيار الصورة - مشكلة في الوصول للمعرض',
    'Analyzing image...': 'جاري تحليل الصورة... - عملية الفحص قيد التنفيذ',
    'Selected image': 'الصورة المحددة - الصورة التي تم اختيارها للتحليل'
  };

  static String getTranslation(String englishText) {
    return _translations[englishText] ?? englishText;
  }
}

// Widget for translated text in Image Analysis
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
      message: ImageAnalysisTranslations.getTranslation(englishText),
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