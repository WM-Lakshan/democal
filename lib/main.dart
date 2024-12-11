/*  IM/2021/060   */

import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart'; // For mathematical expression parsing and evaluation.

void main() {
  runApp(
      CalculatorApp()); // Entry point of the app, running CalculatorApp widget.
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator', // Title of the application.
      theme: ThemeData.dark().copyWith(
        // Sets a dark theme with custom colors.
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: CalculatorScreen(), // The main screen of the calculator.
      debugShowCheckedModeBanner: false, // Hides the debug banner in the app.
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String input = ''; // Stores the current input string.
  String result = ''; // Stores the calculated result.
  bool isResultDisplayed = false; // Flag to check if the result is displayed.
  bool restrictNumberInput =
      false; // Restricts numeric input after specific operators.
  bool restrictAfterSqrt = false; // Restricts input after a square root.

  // Handles button presses and updates input and result accordingly.
  void buttonPressed(String value) {
    // The method is triggered when a button is pressed with the value passed in.
    setState(() {
      // Updates the UI with the new input and result.

      if (value == 'AC') {
        // If the 'AC' (All Clear) button is pressed:
        input = ''; // Clears the input string.
        result = ''; // Clears the result string.
        isResultDisplayed = false; // Resets the result display flag.
        restrictNumberInput = false; // Resets the flag to allow number input.
        restrictAfterSqrt =
            false; // Resets the flag for restricting input after sqrt.
      } else if (value == 'C') {
        // If the 'C' (Clear) button is pressed:
        if (input.isNotEmpty) {
          // If the input is not empty:
          input = input.substring(
              0, input.length - 1); // Removes the last character.
        }
      } else if (value == '=') {
        // If the equals button '=' is pressed (i.e., calculate the result):

        // Ensure all opened sqrt() have closing brackets
        while (input.contains('sqrt(') &&
            input.split('sqrt(').length > input.split(')').length) {
          input += ')'; // Adds missing closing brackets for sqrt functions.
        }

        // Check if division by zero is present (for edge case handling)
        if (input.contains('÷0') && !input.contains('÷0.')) {
          result =
              "Indeterminate"; // Prevents division by zero and displays an error message.
        } else {
          try {
            // Parsing and evaluating the mathematical expression:
            Parser p = Parser(); // Initializes the parser.
            Expression exp = p.parse(input.replaceAll('×', '*').replaceAll('÷',
                '/')); // Converts the input to a valid mathematical expression.
            ContextModel cm = ContextModel(); // Context for evaluation.
            var eval = exp.evaluate(
                EvaluationType.REAL, cm); // Evaluates the expression.

            // Check if the result is an integer or float:
            if (eval == eval.toInt()) {
              result = eval
                  .toInt()
                  .toString(); // If integer, show as integer (no decimals).
            } else {
              result =
                  eval.toString(); // Otherwise, show the result with decimals.
            }

            isResultDisplayed = true; // Marks that result is now displayed.
            restrictNumberInput =
                false; //Allows number imputs after the result.
            restrictAfterSqrt = false; // Allows further input after sqrt.
          } catch (e) {
            result =
                'Error'; // If an error occurs during evaluation, show 'Error'.
          }
        }
      } else if (value == '%') {
        // If '%' button is pressed (percent calculation):
        if (!restrictNumberInput && !restrictAfterSqrt) {
          input +=
              '/100'; // Converts the input to a percentage by dividing by 100.
          restrictNumberInput =
              true; // Restricts further number input after percentage.
        }
      } else if (value == '√') {
        // If the square root button '√' is pressed:
        if (!restrictNumberInput) {
          // If input is not restricted:
          if (input.isNotEmpty && RegExp(r'\d$').hasMatch(input)) {
            input += '×'; // Adds multiplication sign before sqrt if necessary.
          }
          if (input.contains('sqrt(') &&
              input.split('sqrt(').length > input.split(')').length) {
            return; // Prevents adding multiple sqrt() calls without closing brackets.
          } else {
            input += 'sqrt('; // Adds the square root function to the input.
            restrictAfterSqrt =
                true; // Restricts input after sqrt until it is completed.
          }
        }
      } else if (value == '.') {
        // If the decimal button '.' is pressed:
        if (input.isEmpty || '+-×÷'.contains(input[input.length - 1])) {
          input += '0.'; // Adds '0.' to input if it starts with a decimal.
        } else {
          input += '.'; // Otherwise, just add a decimal point.
        }
      } else if (restrictAfterSqrt) {
        // If the input is restricted after sqrt() due to incomplete function:
        if ('+-×÷'.contains(value)) {
          input +=
              ')'; // Add closing parenthesis to complete the sqrt() function.
          restrictAfterSqrt =
              false; // Allow normal input after sqrt completion.
        }
        input += value; // Add the button's value to the input.
      } else {
        // If none of the above conditions match (for regular button presses):

        if (isResultDisplayed) {
          // If result is already displayed:
          if ('+-×÷'.contains(value)) {
            input = result + value; // Start a new calculation from the result.
          } else {
            input = value; // Start a new input after result.
            result = ''; // Clears the previous result.
          }
          isResultDisplayed = false; // Reset result display flag.
          restrictNumberInput = false; // Allow number input after result.
        } else {
          // Regular input handling:
          if (restrictNumberInput) {
            if ('+-×÷'.contains(value)) {
              input += value; // Add operator after restricting number input.
              restrictNumberInput = false; // Allow further input.
            }
          } else {
            // Handle case where the last character is an operator and the same operator is pressed again.
            if (input.isNotEmpty &&
                '+-×÷'.contains(input[input.length - 1]) &&
                '+-×÷'.contains(value)) {
              return; // Prevent consecutive operators (e.g., ++, --).
            }
            if (value == '.' && input == '0') {
              input += value; // If the input is zero, start with decimal.
            } else if (input.length < 25) {
              input +=
                  value; // Limit input length to 25 characters, and append the value.
            }
          }
        }
      }
    });
  }

  // Builds the calculator button widget.
  Widget buildButton(String value,
      {Color color = Colors.blue, Color textColor = Colors.white}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color, // Button background color.
            padding: const EdgeInsets.symmetric(
                vertical: 20), // Padding for buttons.
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // Rounded corners.
            ),
          ),
          onPressed: () =>
              buttonPressed(value), // Calls buttonPressed function.
          child: Text(
            value,
            style: TextStyle(
                fontSize: 24, color: textColor), // Button text styling.
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CALCULATOR'), // App bar title.
      ),
      body: Column(
        mainAxisAlignment:
            MainAxisAlignment.end, // Aligns content to the bottom.
        children: <Widget>[
          // Displays the input text.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            alignment: Alignment.centerRight,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal, // Scrollable for long inputs.
              child: Text(
                input.isEmpty ? '0' : input, // Shows "0" if input is empty.
                style: const TextStyle(fontSize: 30, color: Colors.white),
              ),
            ),
          ),
          // Displays the result text.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            alignment: Alignment.centerRight,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal, // Scrollable for long results.
              child: Text(
                result,
                style: const TextStyle(fontSize: 30, color: Colors.white),
                overflow: TextOverflow.ellipsis, // Truncates if too long.
              ),
            ),
          ),
          // Builds calculator button rows.
          Row(
            children: <Widget>[
              buildButton('AC',
                  color: const Color.fromARGB(255, 242, 199, 58),
                  textColor: Colors.white),
              buildButton('C',
                  color: const Color.fromARGB(255, 242, 199, 58),
                  textColor: Colors.white),
              buildButton('%',
                  color: const Color(0xffea5f5f), textColor: Colors.white),
              buildButton('÷', color: const Color(0xffea5f5f)),
            ],
          ),
          Row(
            children: <Widget>[
              buildButton('7',
                  color: const Color.fromARGB(255, 37, 37, 37),
                  textColor: Colors.white),
              buildButton('8',
                  color: const Color.fromARGB(255, 42, 42, 42),
                  textColor: Colors.white),
              buildButton('9',
                  color: const Color.fromARGB(255, 42, 42, 42),
                  textColor: Colors.white),
              buildButton('×', color: const Color(0xffea5f5f)),
            ],
          ),
          Row(
            children: <Widget>[
              buildButton('4',
                  color: const Color.fromARGB(255, 42, 42, 42),
                  textColor: Colors.white),
              buildButton('5',
                  color: const Color.fromARGB(255, 42, 42, 42),
                  textColor: Colors.white),
              buildButton('6',
                  color: const Color.fromARGB(255, 42, 42, 42),
                  textColor: Colors.white),
              buildButton('-', color: const Color(0xffea5f5f)),
            ],
          ),
          Row(
            children: <Widget>[
              buildButton('1',
                  color: const Color.fromARGB(255, 42, 42, 42),
                  textColor: Colors.white),
              buildButton('2',
                  color: const Color.fromARGB(255, 42, 42, 42),
                  textColor: Colors.white),
              buildButton('3',
                  color: const Color.fromARGB(255, 42, 42, 42),
                  textColor: Colors.white),
              buildButton('+', color: const Color(0xffea5f5f)),
            ],
          ),
          Row(
            children: <Widget>[
              buildButton('0',
                  color: const Color.fromARGB(255, 42, 42, 42),
                  textColor: Colors.white),
              buildButton('.',
                  color: const Color.fromARGB(255, 42, 42, 42),
                  textColor: Colors.white),
              buildButton('=', color: const Color.fromARGB(255, 53, 212, 45)),
              buildButton('√',
                  color: const Color(0xffea5f5f), textColor: Colors.white),
            ],
          ),
        ],
      ),
    );
  }
}
