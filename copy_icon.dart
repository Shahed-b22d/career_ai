import 'dart:io';

void main() {
  File source = File(r'C:\Users\A AR\.gemini\antigravity\brain\8271fded-221d-4f1e-ba40-e7e810d72b36\career_ai_app_logo_1777651442837.png');
  File dest = File(r'c:\Users\A AR\Desktop\career_ai\assets\icons\app_icon.png');
  source.copySync(dest.path);
  print('Copied!');
}
