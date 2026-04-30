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
      
      String finalUserInput = userInput.value
          .replaceAll('x', '*')
          .replaceAll('÷', '/');
      
      // Handle percentage (%) correctly: replace 'number%' with '/100'
      // Example: '20*10%' becomes '20*10/100'
      finalUserInput = finalUserInput.replaceAllMapped(
        RegExp(r'(\d+\.?\d*)%'), 
        (match) => "(${match.group(1)}/100)"
      );

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
    // Note: This is a basic evaluator. For complex expressions with brackets, 
    // a proper shunting-yard or parser would be better.
    // However, our replacement above handles the common cases.
    
    // We need to handle brackets for the (n/100) replacement
    // For now, let's just use a slightly better split to handle the divisions
    String sanitized = expression.replaceAll('(', '').replaceAll(')', '');
    
    final exp = RegExp(r'(\d+\.?\d*)|([+\-*/])');
    var matches = exp.allMatches(sanitized).map((m) => m.group(0)!).toList();
    
    if (matches.isEmpty) return 0;

    // Handle initial negative sign
    if (matches[0] == '-' && matches.length > 1) {
      matches[1] = '-' + matches[1];
      matches.removeAt(0);
    }

    // Pass 1: *, /
    for (int i = 0; i < matches.length; i++) {
      if (matches[i] == '*' || matches[i] == '/') {
        double a = double.parse(matches[i - 1]);
        double b = double.parse(matches[i + 1]);
        double res = 0;
        if (matches[i] == '*') res = a * b;
        if (matches[i] == '/') {
           if (b == 0) throw Exception("Division by zero");
           res = a / b;
        }
        
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
