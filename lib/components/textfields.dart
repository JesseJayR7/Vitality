import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:vitality/components/strings.dart';

class LightTextFieldsText extends StatefulWidget {
  const LightTextFieldsText({
    super.key,
    required this.title,
    required this.controller,
    required this.prefixIcon,
  });
  final String title;
  final TextEditingController? controller;
  final Widget? prefixIcon;

  @override
  State<LightTextFieldsText> createState() => _LightTextFieldsTextState();
}

class _LightTextFieldsTextState extends State<LightTextFieldsText> {
  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;
    return Column(
      children: [
        SizedBox(
          height: mediaQuery.height * 0.020,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            widget.title,
            style: TextStyle(
              fontSize: mediaQuery.width * 0.055,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            softWrap: true,
          ),
        ),
        SizedBox(
          height: mediaQuery.height * 0.005,
        ),
        TextFormField(
          controller: widget.controller,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a ${widget.title}';
            }
            return null;
          },
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          cursorColor: Theme.of(context).colorScheme.onSurface,
          decoration: InputDecoration(
            errorMaxLines: 3,
            prefixIcon: widget.prefixIcon,
            prefixIconColor: Theme.of(context).colorScheme.onSurface,
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    width: 2, color: Theme.of(context).colorScheme.primary)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    width: 3, color: Theme.of(context).colorScheme.secondary)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    width: 2, color: Theme.of(context).colorScheme.error)),
            focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    width: 3, color: Theme.of(context).colorScheme.error)),
          ),
        ),
      ],
    );
  }
}

class LightTextFieldsEmail extends StatefulWidget {
  const LightTextFieldsEmail({
    super.key,
    required this.title,
    required this.controller,
    required this.prefixIcon,
  });
  final String title;
  final TextEditingController? controller;
  final Widget? prefixIcon;

  @override
  State<LightTextFieldsEmail> createState() => _LightTextFieldsEmailState();
}

class _LightTextFieldsEmailState extends State<LightTextFieldsEmail> {
  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;
    return Column(
      children: [
        SizedBox(
          height: mediaQuery.height * 0.020,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            widget.title,
            style: TextStyle(
              fontSize: mediaQuery.width * 0.055,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            softWrap: true,
          ),
        ),
        SizedBox(
          height: mediaQuery.height * 0.005,
        ),
        TextFormField(
          controller: widget.controller,
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter an email';
            } else if (!emailRegExp.hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          cursorColor: Theme.of(context).colorScheme.onSurface,
          decoration: InputDecoration(
            errorMaxLines: 3,
            prefixIcon: widget.prefixIcon,
            prefixIconColor: Theme.of(context).colorScheme.onSurface,
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    width: 2, color: Theme.of(context).colorScheme.primary)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    width: 3, color: Theme.of(context).colorScheme.secondary)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    width: 2, color: Theme.of(context).colorScheme.error)),
            focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    width: 3, color: Theme.of(context).colorScheme.error)),
          ),
        ),
      ],
    );
  }
}

// ignore: must_be_immutable
class LightTextFieldsPassword extends StatefulWidget {
  LightTextFieldsPassword({
    super.key,
    required this.title,
    required this.controller,
    required this.prefixIcon,
    required this.suffixIcon,
    required this.obscurePassword,
    required this.errorMsg,
  });
  final String title;
  final TextEditingController? controller;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  bool obscurePassword;
  String? errorMsg;

  @override
  State<LightTextFieldsPassword> createState() =>
      _LightTextFieldsPasswordState();
}

class _LightTextFieldsPasswordState extends State<LightTextFieldsPassword> {
  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;
    return Column(
      children: [
        SizedBox(
          height: mediaQuery.height * 0.020,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            widget.title,
            style: TextStyle(
              fontSize: mediaQuery.width * 0.055,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            softWrap: true,
          ),
        ),
        SizedBox(
          height: mediaQuery.height * 0.005,
        ),
        TextFormField(
          controller: widget.controller,
          obscureText: widget.obscurePassword,
          keyboardType: TextInputType.visiblePassword,
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter a password';
            } else if (!passwordRegExp.hasMatch(value)) {
              return 'Please enter a valid password. It must contain at least:\n- One lowercase letter (a-z)\n- One uppercase letter (A-Z)\n- One digit (0-9)\n- One special character\n- Minimum 8 characters.';
            }

            return null;
          },
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          cursorColor: Theme.of(context).colorScheme.onSurface,
          decoration: InputDecoration(
            errorMaxLines: 10,
            errorText: widget.errorMsg,
            prefixIcon: widget.prefixIcon,
            prefixIconColor: Theme.of(context).colorScheme.onSurface,
            suffixIcon: widget.suffixIcon,
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    width: 2, color: Theme.of(context).colorScheme.primary)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    width: 3, color: Theme.of(context).colorScheme.secondary)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    width: 2, color: Theme.of(context).colorScheme.error)),
            focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    width: 3, color: Theme.of(context).colorScheme.error)),
          ),
        ),
      ],
    );
  }
}

class LightTextFieldsDate extends StatefulWidget {
  const LightTextFieldsDate({
    super.key,
    required this.title,
    required this.controller,
    required this.prefixIcon,
  });
  final String title;
  final TextEditingController? controller;
  final Widget? prefixIcon;

  @override
  State<LightTextFieldsDate> createState() => _LightTextFieldsDateState();
}

class _LightTextFieldsDateState extends State<LightTextFieldsDate> {
  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;
    return Column(
      children: [
        SizedBox(
          height: mediaQuery.height * 0.020,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            widget.title,
            style: TextStyle(
              fontSize: mediaQuery.width * 0.055,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            softWrap: true,
          ),
        ),
        SizedBox(
          height: mediaQuery.height * 0.005,
        ),
        TextFormField(
          controller: widget.controller,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a ${widget.title}';
            }
            return null;
          },
          onTap: () async {
            FocusScope.of(context).requestFocus(FocusNode());

            DateTime? pickedDate = await showDatePicker(
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: Theme.of(context).colorScheme.primary,
                      onPrimary: Theme.of(context).colorScheme.surface,
                      onSurface: Theme.of(context).colorScheme.primary,
                    ),
                    textButtonTheme: TextButtonThemeData(
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  child: child!,
                );
              },
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime(3000),
            );

            if (pickedDate != null) {
              setState(() {
                widget.controller?.text =
                    DateFormat('dd-MM-yyyy').format(pickedDate);
              });
            }
          },
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          cursorColor: Theme.of(context).colorScheme.onSurface,
          decoration: InputDecoration(
            errorMaxLines: 3,
            prefixIcon: widget.prefixIcon,
            prefixIconColor: Theme.of(context).colorScheme.onSurface,
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    width: 2, color: Theme.of(context).colorScheme.primary)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    width: 3, color: Theme.of(context).colorScheme.secondary)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    width: 2, color: Theme.of(context).colorScheme.error)),
            focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    width: 3, color: Theme.of(context).colorScheme.error)),
          ),
        ),
      ],
    );
  }
}

class LightTextFieldsNumber extends StatefulWidget {
  const LightTextFieldsNumber({
    super.key,
    required this.title,
    required this.controller,
    required this.prefixIcon,
  });
  final String title;
  final TextEditingController? controller;
  final Widget? prefixIcon;

  @override
  State<LightTextFieldsNumber> createState() => _LightTextFieldsNumberState();
}

class _LightTextFieldsNumberState extends State<LightTextFieldsNumber> {
  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;
    return Column(
      children: [
        SizedBox(
          height: mediaQuery.height * 0.020,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            widget.title,
            style: TextStyle(
              fontSize: mediaQuery.width * 0.055,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            softWrap: true,
          ),
        ),
        SizedBox(
          height: mediaQuery.height * 0.005,
        ),
        TextFormField(
          controller: widget.controller,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a ${widget.title}';
            }
            return null;
          },
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          cursorColor: Theme.of(context).colorScheme.onSurface,
          decoration: InputDecoration(
            errorMaxLines: 3,
            prefixIcon: widget.prefixIcon,
            prefixIconColor: Theme.of(context).colorScheme.onSurface,
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    width: 2, color: Theme.of(context).colorScheme.primary)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    width: 3, color: Theme.of(context).colorScheme.secondary)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    width: 2, color: Theme.of(context).colorScheme.error)),
            focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    width: 3, color: Theme.of(context).colorScheme.error)),
          ),
        ),
      ],
    );
  }
}


class LightTextFieldsTime extends StatefulWidget {
  const LightTextFieldsTime({
    super.key,
    required this.title,
    required this.controller,
    required this.prefixIcon,
  });

  final String title;
  final TextEditingController? controller;
  final Widget? prefixIcon;

  @override
  State<LightTextFieldsTime> createState() => _LightTextFieldsTimeState();
}

class _LightTextFieldsTimeState extends State<LightTextFieldsTime> {
  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: mediaQuery.height * 0.020,
        ),
        Text(
          widget.title,
          style: TextStyle(
            fontSize: mediaQuery.width * 0.055,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        SizedBox(
          height: mediaQuery.height * 0.005,
        ),
        TextFormField(
          controller: widget.controller,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a ${widget.title}';
            }
            return null;
          },
          onTap: () async {
            TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: const TimeOfDay(hour: 0, minute: 0),
              initialEntryMode: TimePickerEntryMode.input,
              builder: (BuildContext context, Widget? child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                  child: child!,
                );
              },
            );

            if (pickedTime != null) {
              setState(() {
                widget.controller?.text =
                    '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
              });
            }
          },
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
          cursorColor: Theme.of(context).colorScheme.surface,
          decoration: InputDecoration(
            errorMaxLines: 3,
            prefixIcon: widget.prefixIcon,
            prefixIconColor: Theme.of(context).colorScheme.primary,
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                width: 2,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                width: 3,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                width: 2,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                width: 3,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
