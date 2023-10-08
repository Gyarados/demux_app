import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RangeInputFormatter extends TextInputFormatter {
  final RegExp _regex = RegExp(r'^(0(\.\d{0,2})?|1(\.\d{0,2})?|2(\.0{0,2})?)$');

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // If the new value is empty or matches the regex, return it as is.
    if (newValue.text.isEmpty || _regex.hasMatch(newValue.text)) {
      return newValue;
    }
    // Otherwise, use the old value (i.e., don't allow the change).
    return oldValue;
  }
}

Widget getTemperatureInputWidget(TextEditingController temperatureController,
    bool loading, Function(String) onTemperatureChanged) {
  return TextField(
    inputFormatters: [
      RangeInputFormatter(),
    ],
    enabled: !loading,
    textAlign: TextAlign.center,
    controller: temperatureController,
    onChanged: onTemperatureChanged,
    decoration: InputDecoration(
      labelText: 'Temperature',
      contentPadding: EdgeInsets.all(0.0),
    ),
    keyboardType: TextInputType.number,
  );
}
