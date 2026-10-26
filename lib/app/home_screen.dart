import 'package:flutter/material.dart';
import 'package:solenn/features/calculator/presentation/view/calculator_page.dart';

/// Home of the application: the calculator.
///
/// The subscription slots are filled here once
/// the subscription feature exists.
class HomeScreen extends StatelessWidget {
  /// Creates the home screen.
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => const CalculatorPage();
}
