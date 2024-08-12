import 'package:flutter/material.dart';

class WeightHeightPicker extends StatefulWidget {
  const WeightHeightPicker({super.key, required this.weightValue, required this.heightValue, required this.weightUnit, required this.heightUnit, required this.onChangedWeight, required this.onChangedHeight, required this.onUnitChangedWeight, required this.onUnitChangedHeight});
  final double weightValue;
  final double heightValue;
  final String weightUnit;
  final String heightUnit;
  final void Function(double) onChangedWeight;
  final void Function(double) onChangedHeight;
  final void Function(String) onUnitChangedWeight;
  final void Function(String) onUnitChangedHeight;

  @override
  State<WeightHeightPicker> createState() => _WeightHeightPickerState();
}

class _WeightHeightPickerState extends State<WeightHeightPicker> {
  final double _minWeightKg = 40.0;
  final double _maxWeightKg = 150.0;
  final double _minWeightLbs = 88.0;
  final double _maxWeightLbs = 330.0;
  final double _minHeightCm = 100.0;
  final double _maxHeightCm = 220.0;
  final double _minHeightIn = 39.4;
  final double _maxHeightIn = 86.6;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildWeightPicker(),
        const SizedBox(height: 20),
        _buildHeightPicker(),
      ],
    );
  }

  Widget _buildWeightPicker() {
    return _buildPicker(
      label: "WEIGHT",
      value: widget.weightValue,
      minValue: widget.weightUnit == 'kg' ? _minWeightKg : _minWeightLbs,
      maxValue: widget.weightUnit == 'kg' ? _maxWeightKg : _maxWeightLbs,
      unit: widget.weightUnit,
      onChanged: widget.onChangedWeight,
      onUnitChanged: widget.onUnitChangedWeight,
    );
  }

  Widget _buildHeightPicker() {
    return _buildPicker(
      label: "HEIGHT",
      value: widget.heightValue,
      minValue: widget.heightUnit == 'cm' ? _minHeightCm : _minHeightIn,
      maxValue: widget.heightUnit == 'cm' ? _maxHeightCm : _maxHeightIn,
      unit: widget.heightUnit,
      onChanged: widget.onChangedHeight,
      onUnitChanged: widget.onUnitChangedHeight,
    );
  }

  Widget _buildPicker({
    required String label,
    required double value,
    required double minValue,
    required double maxValue,
    required String unit,
    required ValueChanged<double> onChanged,
    required ValueChanged<String> onUnitChanged,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 16)),
            DropdownButton<String>(
              value: unit,
              items: (label == "WEIGHT"
                      ? ['kg', 'lbs']
                      : ['cm', 'in'])
                  .map((String unit) {
                return DropdownMenuItem<String>(
                  value: unit,
                  child: Text(unit),
                );
              }).toList(),
              onChanged: (unit) {
                onUnitChanged(unit!);
              },
            ),
            Text(value.toStringAsFixed(0), style: TextStyle(fontSize: 16)),
          ],
        ),
        Slider(
          value: value,
          min: minValue,
          max: maxValue,
          divisions: (maxValue - minValue).toInt(),
          label: value.toStringAsFixed(0),
          onChanged: onChanged,
          inactiveColor: Theme.of(context).colorScheme.secondary,
        ),
      ],
    );
  }
}
