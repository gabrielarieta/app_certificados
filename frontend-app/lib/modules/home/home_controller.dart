import 'package:flutter/material.dart';

class HomeController extends ChangeNotifier {
  // Example state variable
  String _title = 'Home';

  String get title => _title;

  void updateTitle(String newTitle) {
    _title = newTitle;
    notifyListeners();
  }

  // Add more logic and state management as needed
}