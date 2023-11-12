import 'package:flutter/material.dart';

class DoubleSliderWidget extends StatelessWidget {
  final double min;
  final double max;
  final double defaultValue;
  final double currentValue;
  final String label;
  final int divisions;
  final int fractionDigits;
  final Function onChanged;

  DoubleSliderWidget({
    required this.min,
    required this.max,
    required this.divisions,
    this.fractionDigits = 1,
    required this.defaultValue,
    required this.currentValue,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              "$label: ${currentValue.toStringAsFixed(fractionDigits)}"),
          Row(
            children: [
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    overlayShape: RoundSliderOverlayShape(overlayRadius: 0),
                  ),
                  child: Slider(
                    divisions: divisions,
                    label: currentValue.toStringAsFixed(fractionDigits),
                    activeColor: Colors.blueGrey,
                    value: currentValue,
                    min: min,
                    max: max,
                    onChanged: (value) {
                        onChanged(value);
                    },
                  ),
                ),
              ),
              SizedBox(
                width: 8,
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red,
                ),
                child: Text('Reset'),
                onPressed: () {
                    onChanged(defaultValue);
                },
              )
            ],
          ),
        ],
      ),
    );
  }
}
