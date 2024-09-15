import 'package:flutter/material.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeData _currentTheme = ThemeData.light();

  ThemeData get currentTheme => _currentTheme;

  void toggleTheme() {
    if (_currentTheme == ThemeData.light()) {
      _currentTheme = ThemeData.dark();
    } else {
      _currentTheme = ThemeData.light();
    }
    notifyListeners();
  }
}


// final Gemini _gemini = Gemini.init(
//       apiKey:
//           'AIzaSyByqRx5KdhwEAHvyh7j2z5j0PpHC46UK1w');


//  ListTile(
//                 title: const Text('Toggle Theme'),
//                 trailing: Icon(themeNotifier.currentTheme == ThemeData.light()
//                     ? Icons.dark_mode
//                     : Icons.light_mode),
//                 onTap: () {
//                   themeNotifier.toggleTheme();
//                 },
//               ),