import 'package:flutter/material.dart';

class LightShortButton extends StatelessWidget {
  const LightShortButton(
      {super.key,
      required this.onPress,
      required this.title,});
  final VoidCallback onPress;
  final String title;
  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;
    return ElevatedButton(
      
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Theme.of(context).colorScheme.onSurface,
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.015,
          horizontal: MediaQuery.of(context).size.width * 0.040,
        ),
      ),
      onPressed: onPress,
      child: Text(
        title,
        style:
            TextStyle(fontSize: mediaQuery.height * 0.03, color: Theme.of(context).colorScheme.surface),
      ),
    );
  }
}

class LightSecondaryShortButton extends StatelessWidget {
  const LightSecondaryShortButton(
      {super.key,
      required this.onPress,
      required this.title,});
  final VoidCallback onPress;
  final String title;
  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;
    return ElevatedButton(
      
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.015,
          horizontal: MediaQuery.of(context).size.width * 0.040,
        ),
      ),
      onPressed: onPress,
      child: Text(
        title,
        style:
            TextStyle(fontSize: mediaQuery.height * 0.03, color: Theme.of(context).colorScheme.surface),
      ),
    );
  }
}

class LightPrimaryShortButton extends StatelessWidget {
  const LightPrimaryShortButton(
      {super.key,
      required this.onPress,
      required this.title,});
  final VoidCallback onPress;
  final String title;
  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;
    return ElevatedButton(
      
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.015,
          horizontal: MediaQuery.of(context).size.width * 0.040,
        ),
      ),
      onPressed: onPress,
      child: Text(
        title,
        style:
            TextStyle(fontSize: mediaQuery.height * 0.03, color: Theme.of(context).colorScheme.surface),
      ),
    );
  }
}

class LightSmallButton extends StatelessWidget {
  const LightSmallButton(
      {super.key,
      required this.onPress,
      required this.title,});
  final VoidCallback onPress;
  final String title;
  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;
    return ElevatedButton(
      
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.015,
          horizontal: MediaQuery.of(context).size.width * 0.040,
        ),
      ),
      onPressed: onPress,
      child: Text(
        title,
        style:
            TextStyle(fontSize: mediaQuery.height * 0.015, color: Theme.of(context).colorScheme.surface),
      ),
    );
  }
}

class LightSmallButtonError extends StatelessWidget {
  const LightSmallButtonError(
      {super.key,
      required this.onPress,
      required this.title,});
  final VoidCallback onPress;
  final String title;
  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;
    return ElevatedButton(
      
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.015,
          horizontal: MediaQuery.of(context).size.width * 0.040,
        ),
      ),
      onPressed: onPress,
      child: Text(
        title,
        style:
            TextStyle(fontSize: mediaQuery.height * 0.015, color: Theme.of(context).colorScheme.surface),
      ),
    );
  }
}
