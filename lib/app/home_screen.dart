import 'package:flutter/material.dart';
import 'package:solenn/features/calculator/presentation/view/calculator_view.dart';

/// Home of the application.
///
/// Renders the calculator interface with an idle state. Key presses are not
/// handled yet: the calculator Cubit arrives with the domain,
/// and the subscription slots are filled with the subscription feature.
class HomeScreen extends StatelessWidget {
  /// Creates the home screen.
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CalculatorView(
      expression: '',
      result: '0',
      onKeyPressed: (_) {},
    );
  }
}
