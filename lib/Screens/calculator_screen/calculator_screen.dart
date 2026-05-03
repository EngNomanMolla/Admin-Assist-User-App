import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_widgets/controller/calculator_controller.dart';

class CalculatorScreen extends StatelessWidget {
  final CalculatorController controller = Get.put(CalculatorController());

  CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F4F6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black54),
          onPressed: () => Get.back(), 
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF3F4F6),
        ),
        child: Column(
          children: [
            // Display Section
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Obx(() => Text(
                            controller.userInput.value,
                            style: const TextStyle(
                              fontSize: 28,
                              color: Colors.black54,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                            ),
                          )),
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Obx(() => Text(
                            controller.result.value,
                            style: const TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                              fontFamily: 'Inter',
                              letterSpacing: -1.5,
                            ),
                          )),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => controller.onButtonPressed('C'),
                      onLongPress: () => controller.onButtonPressed('AC'),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.backspace_outlined,
                          size: 20,
                          color: Colors.orangeAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Buttons Section
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildButtonRow(['AC', 'C', '%', '÷'], [Colors.redAccent, Colors.orangeAccent, const Color(0xFF7B61FF), const Color(0xFF7B61FF)]),
                  const SizedBox(height: 8),
                  _buildButtonRow(['7', '8', '9', 'x'], [Colors.black87, Colors.black87, Colors.black87, const Color(0xFF7B61FF)]),
                  const SizedBox(height: 8),
                  _buildButtonRow(['4', '5', '6', '-'], [Colors.black87, Colors.black87, Colors.black87, const Color(0xFF7B61FF)]),
                  const SizedBox(height: 8),
                  _buildButtonRow(['1', '2', '3', '+'], [Colors.black87, Colors.black87, Colors.black87, const Color(0xFF7B61FF)]),
                  const SizedBox(height: 8),
                  _buildButtonRow(['00', '0', '.', '='], [Colors.black87, Colors.black87, Colors.black87, Colors.green]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonRow(List<String> labels, List<Color> colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(4, (index) {
        if (labels[index].isEmpty) {
          return const SizedBox(width: 70, height: 70); // Empty space
        }
        return _buildButton(labels[index], colors[index]);
      }),
    );
  }

  Widget _buildButton(String text, Color textColor) {
    bool isOperator = ['÷', 'x', '-', '+', '=', '%'].contains(text);
    bool isClear = ['AC', 'C'].contains(text);
    
    Color bgColor = isOperator ? textColor.withOpacity(0.1) : Colors.grey.shade50;
    if (text == '=') {
      bgColor = textColor; // Green background for equals
      textColor = Colors.white;
    } else if (isClear) {
      bgColor = textColor.withOpacity(0.1);
    }

    return GestureDetector(
      onTap: () => controller.onButtonPressed(text),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: text == 'AC' ? 20 : 28,
              fontWeight: FontWeight.w600,
              color: textColor,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ),
    );
  }
}
