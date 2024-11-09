import 'package:flutter/material.dart';
import 'package:qasida_gpt/screens/poem_generator_screen.dart';
import '../screens/chat_screen.dart'; 
import '../screens/analysis_screen.dart'; 

class NavigationController extends ChangeNotifier {
  // Selected index for the NavigationRail
  int _selectedIndex = 0;

  // Getter to expose selected index
  int get selectedIndex => _selectedIndex;

  // Function to change the selected index
  void onDestinationSelected(int index) {
    _selectedIndex = index;
    notifyListeners(); // Notify listeners (e.g., UI) that the selected index has changed
  }

  // Function to toggle the navigation rail extension
  bool _isNavigationRailExtended = false;
  bool get isNavigationRailExtended => _isNavigationRailExtended;

  void toggleNavigationRail() {
    _isNavigationRailExtended = !_isNavigationRailExtended;
    notifyListeners();
  }

  // Function to build the current screen based on the selected index
  Widget buildCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return const PoemGenerator();
      case 1:
        return const PoemAnalysisScreen();
      case 2:
        return const ChatScreen();
      default:
        return const PoemGenerator();
    }
  }
}
