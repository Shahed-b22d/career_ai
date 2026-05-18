import 'package:flutter/material.dart';

import '../services/local_storage_service.dart';

class LocaleProvider extends StatefulWidget {
  final Widget child;
  const LocaleProvider({required this.child, super.key});

  static LocaleController of(BuildContext context) {
    final state = context.findAncestorStateOfType<_LocaleProviderState>();
    return LocaleController._(state);
  }

  @override
  _LocaleProviderState createState() => _LocaleProviderState();
}

class _LocaleProviderState extends State<LocaleProvider> {
  String _locale = 'en';

  Map<String, Map<String, String>> _translations = {
    'en': {
      'edit_profile': 'Edit Profile',
      'company_profile': 'Company Profile',
      'company_name': 'Company Name',
      'company_description': 'Company Description',
      'full_name': 'Full Name',
      'email': 'Email',
      'phone': 'Phone',
      'select_region': 'Select Region',
      'save_changes': 'Save Changes',
      'logout': 'Logout',
      'create_account': 'Create Account',
      'join_text': 'Join CareerAI to accelerate your growth.',
      'accept_terms': 'I agree to the Terms of Service & Privacy Policy',
      'upload_register': 'Upload Commercial Register',
      'file_selected': 'File Selected ✓',
      'select_business_type': 'Select Business Type',
      'password': 'Password',
      'confirm_password': 'Confirm Password',
      'job_seeker': 'Job Seeker',
      'company': 'Company',
      'updated_success': 'Updated Successfully ✅',
      'saved_success': 'Saved successfully ✅',
      'logout_title': 'Logout',
      'logout_msg': 'Are you sure you want to logout?',
      'cancel': 'Cancel',
    },
    'ar': {
      'edit_profile': 'تعديل الملف الشخصي',
      'company_profile': 'بروفايل الشركة',
      'company_name': 'اسم الشركة',
      'company_description': 'وصف الشركة',
      'full_name': 'الاسم الكامل',
      'email': 'البريد الإلكتروني',
      'phone': 'الهاتف',
      'select_region': 'اختر المحافظة',
      'save_changes': 'حفظ التغييرات',
      'logout': 'تسجيل الخروج',
      'create_account': 'إنشاء حساب',
      'join_text': 'انضم إلى CareerAI لتسريع نموك.',
      'accept_terms': 'أوافق على شروط الخدمة و سياسة الخصوصية',
      'upload_register': 'رفع السجل التجاري',
      'file_selected': 'الملف محدد ✓',
      'select_business_type': 'اختر نوع النشاط',
      'password': 'كلمة المرور',
      'confirm_password': 'تأكيد كلمة المرور',
      'job_seeker': 'باحث عن عمل',
      'company': 'شركة',
      'updated_success': 'تم التحديث بنجاح ✅',
      'saved_success': 'تم الحفظ بنجاح ✅',
      'logout_title': 'تسجيل الخروج',
      'logout_msg': 'هل أنت متأكد من أنك تريد تسجيل الخروج؟',
      'cancel': 'إلغاء',
    }
  };

  String get locale => _locale;

  Future<void> loadLocale() async {
    final l = await LocalStorageService.getAppLocale();
    setState(() {
      _locale = l ?? 'en';
    });
  }

  String t(String key) {
    return _translations[_locale]?[key] ?? key;
  }

  void setLocale(String l) {
    setState(() {
      _locale = l;
    });
    LocalStorageService.saveAppLocale(l);
  }

  @override
  void initState() {
    super.initState();
    loadLocale();
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedLocale(
      data: this,
      child: widget.child,
    );
  }
}

class _InheritedLocale extends InheritedWidget {
  final _LocaleProviderState data;
  const _InheritedLocale({required this.data, required super.child});

  @override
  bool updateShouldNotify(covariant _InheritedLocale oldWidget) => true;
}


class LocaleController {
  final _LocaleProviderState? _state;
  LocaleController._(this._state);

  String get locale => _state?._locale ?? 'en';
  String t(String key) => _state?._translations[_state!._locale]?[key] ?? key;
  void setLocale(String l) {
    if (_state != null) _state!.setLocale(l);
  }
}

// Convenience short access
String L(BuildContext c, String key) {
  try {
    return LocaleProvider.of(c).t(key);
  } catch (_) {
    return key;
  }
}

