import 'package:flutter/foundation.dart';

class pageProviderService extends ChangeNotifier {
  int _page = 0;

  int get page => _page;

  void goToPage(int pageNumber) {
    _page = pageNumber;
    notifyListeners();
  }
}
