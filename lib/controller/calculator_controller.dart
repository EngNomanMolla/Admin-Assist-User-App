import 'package:get/get.dart';

class CalculatorController extends GetxController {
  var userInput = ''.obs;
  var result = '0'.obs;

  void onButtonPressed(String text) {
    if (text == 'AC') {
      userInput.value = '';
      result.value = '0';
      return;
    }

    if (text == 'C') {
      if (userInput.value.isNotEmpty) {
        userInput.value = userInput.value.substring(0, userInput.value.length - 1);
      }
      return;
    }

    if (text == '=') {
      _calculateResult();
      return;
    }

    userInput.value += text;
  }

  void _calculateResult() {
    try {
      if (userInput.value.isEmpty) return;
      
      String finalUserInput = userInput.value.replaceAll('x', '*').replaceAll('÷', '/');
      result.value = _simpleEval(finalUserInput).toString();
      
      // Remove trailing .0 for clean integers
      if (result.value.endsWith('.0')) {
        result.value = result.value.substring(0, result.value.length - 2);
      }
    } catch (e) {
      result.value = 'Error';
    }
  }

  double _simpleEval(String expression) {
    // Basic regex split to extract numbers and operators
    final exp = RegExp(r'(\d+\.?\d*)|([+\-*/%])');
    var matches = exp.allMatches(expression).map((m) => m.group(0)!).toList();
    
    if (matches.isEmpty) return 0;

    // Handle initial negative sign
    if (matches[0] == '-' && matches.length > 1) {
      matches[1] = '-' + matches[1];
      matches.removeAt(0);
    }

    // Pass 1: *, /, %
    for (int i = 0; i < matches.length; i++) {
      if (matches[i] == '*' || matches[i] == '/' || matches[i] == '%') {
        double a = double.parse(matches[i - 1]);
        double b = double.parse(matches[i + 1]);
        double res = 0;
        if (matches[i] == '*') res = a * b;
        if (matches[i] == '/') res = a / b;
        if (matches[i] == '%') res = a % b;
        
        matches[i - 1] = res.toString();
        matches.removeRange(i, i + 2);
        i--;
      }
    }

    // Pass 2: +, -
    for (int i = 0; i < matches.length; i++) {
      if (matches[i] == '+' || matches[i] == '-') {
        double a = double.parse(matches[i - 1]);
        double b = double.parse(matches[i + 1]);
        double res = 0;
        if (matches[i] == '+') res = a + b;
        if (matches[i] == '-') res = a - b;
        
        matches[i - 1] = res.toString();
        matches.removeRange(i, i + 2);
        i--;
      }
    }

    return double.parse(matches[0]);
  }
}
