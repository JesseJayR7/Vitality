import 'package:flutter/material.dart';

// ignore: must_be_immutable
class GenderPicker extends StatefulWidget {
  GenderPicker({super.key, required this.onTap, required this.title, required this.isSelected, required this.iconData});
  void Function() onTap;
  final String title;
  bool isSelected;
  final IconData iconData;

  @override
  State<GenderPicker> createState() => _GenderPickerState();
}

class _GenderPickerState extends State<GenderPicker> {

  

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;

    return  GestureDetector(
      onTap: widget.onTap,
      child: Card(
        color: widget.isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
        elevation: widget.isSelected ? 8 : 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: widget.isSelected ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2) : BorderSide.none,
        ),
        child: SizedBox(
          width: mediaQuery.width * 0.25,
          height: mediaQuery.height * 0.15,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.iconData, size: mediaQuery.width * 0.12, color: Theme.of(context).colorScheme.onSurface),
              SizedBox(height: mediaQuery.height * 0.01),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: mediaQuery.width * 0.045,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  
  }
}
