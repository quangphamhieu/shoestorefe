import 'package:flutter/material.dart';

class MenuProvider with ChangeNotifier {
  String _selectedMenu = '/dashboard';

  String get selectedMenu => _selectedMenu;

  void selectMenu(String menu) {
    _selectedMenu = menu;
    notifyListeners();
  }
}
