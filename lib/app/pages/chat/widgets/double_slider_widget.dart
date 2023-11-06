import 'package:flutter/material.dart';

class DoubleSliderWidget extends StatefulWidget {
  final double min;
  final double max;
  final double defaultValue;
  final double currentValue;
  final String label;
  final int divisions;
  final Function onChanged;
  final Function onReset;

  DoubleSliderWidget(
      {required this.min,
      required this.max,
      required this.divisions,
      required this.defaultValue,
      required this.currentValue,
      required this.label,
      required this.onChanged,
      required this.onReset});

  @override
  _DoubleSliderWidgetState createState() => _DoubleSliderWidgetState();
}

class _DoubleSliderWidgetState extends State<DoubleSliderWidget> {
  late double _currentValue = widget.currentValue;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _currentValue = widget.currentValue;
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("${widget.label}: ${_currentValue.toStringAsFixed(1)}"),
          Row(
            children: [
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    overlayShape: RoundSliderOverlayShape(overlayRadius: 0),
                  ),
                  child: Slider(
                    divisions: widget.divisions,
                    label: _currentValue.toStringAsFixed(1),
                    activeColor: Colors.blueGrey,
                    value: _currentValue,
                    min: widget.min,
                    max: widget.max,
                    onChanged: (value) {
                      setState(() {
                        _currentValue = value;
                        widget.onChanged(value);
                      });
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
                  setState(() {
                    _currentValue = widget.defaultValue;
                    widget.onReset();
                  });
                },
              )
            ],
          ),
        ],
      ),
    );
  }
}
