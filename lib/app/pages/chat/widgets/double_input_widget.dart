import 'package:flutter/material.dart';

class DoubleInputWidget extends StatefulWidget {
  final TextEditingController textEditingController;
  final double? min;
  final double? max;
  final int fractionDigits;
  final String label;
  final bool allowNull;
  final bool enabled;
  const DoubleInputWidget(this.textEditingController,
      {super.key,
      this.label = "",
      this.min,
      this.max,
      this.fractionDigits = 2,
      this.allowNull = true,
      this.enabled = true,
      });

  @override
  State<DoubleInputWidget> createState() => _DoubleInputWidgetState();
}

class _DoubleInputWidgetState extends State<DoubleInputWidget> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      autovalidateMode: AutovalidateMode.always,
      key: _formKey,
      child: TextFormField(
        enabled: widget.enabled,
        controller: widget.textEditingController,
        validator: (value) {
          try {
            if (widget.allowNull && (value == null || value == "")) {
              return null;
            }
            double val = double.parse(value!);
            if ((widget.min != null && val < widget.min!) ||
                (widget.max != null && val > widget.max!)) {
              return 'Enter a value between ${widget.min!.toStringAsFixed(widget.fractionDigits)} and ${widget.max!.toStringAsFixed(widget.fractionDigits)}';
            }
          } catch (e) {
            return 'Enter a valid number';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: widget.label,
          errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
          ),
        ),
      ),
    );
  }
}
