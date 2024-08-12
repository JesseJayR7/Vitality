import 'package:flutter/material.dart';

class SmallAnyCards extends StatefulWidget {
  const SmallAnyCards({super.key, required this.child, required this.backgroundColor});
  final Widget child;
  final Color backgroundColor;

  @override
  State<SmallAnyCards> createState() => _SmallAnyCardsState();
}

class _SmallAnyCardsState extends State<SmallAnyCards> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
            BoxShadow(
              offset: const Offset(0, 10),
              color: Theme.of(context).colorScheme.outline,
              blurRadius: 10.0,
            ),]
          ),
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 25.0, bottom: 15.0),
          child: widget.child,
        ),
      ),
    );
  }
}