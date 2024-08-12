import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:user_repository/user_repository.dart';
import 'package:vitality/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:vitality/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:vitality/blocs/sign_up_bloc/sign_up_bloc.dart';
import 'package:vitality/components/button.dart';
import 'package:vitality/components/gender_picker.dart';
import 'package:vitality/components/textfields.dart';
import 'package:vitality/components/weight_height_picker.dart';
import 'package:vitality/screens/log_in_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmpasswordController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateofBirthController = TextEditingController();

  String? errorMsg;
  bool obscurePassword = true;
  IconData iconPassword = Icons.visibility_off;
  final TextEditingController _emailController = TextEditingController();
  String? selectedGender;

  double _weight = 68.0;
  double _height = 172.0;

  String _weightUnit = 'kg';
  String _heightUnit = 'cm';

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
    var mediaQuery = MediaQuery.of(context).size;
    return BlocBuilder<SignUpBloc, SignUpState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 70,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: mediaQuery.width * 0.12,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    children: [
                      const TextSpan(
                        text: 'Vita',
                      ),
                      TextSpan(
                        text: 'lity',
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .secondary, // Change the color of the number "15" to green
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: mediaQuery.width * 0.03,
                ),
                Container(
                  width: mediaQuery.width * 0.12, // Adjust width as needed
                  height: mediaQuery.width * 0.12, // Adjust height as needed
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    backgroundImage: const AssetImage('images/logo.jpg'),
                    radius: mediaQuery.width * 0.125, // Adjust radius as needed
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant, // Background color inside the CircleAvatar
                  ),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.surface,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text(
                      'Sign Up',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: mediaQuery.width * 0.08,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    LightTextFieldsText(
                        title: 'Name',
                        controller: _nameController,
                        prefixIcon: const Icon(Icons.person)),
                    LightTextFieldsEmail(
                        title: 'Email',
                        controller: _emailController,
                        prefixIcon: const Icon(Icons.email)),
                    LightTextFieldsPassword(
                      title: 'Password',
                      controller: _passwordController,
                      prefixIcon: const Icon(Icons.lock),
                      obscurePassword: obscurePassword,
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: IconButton(
                          icon: Icon(
                            iconPassword,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                              if (obscurePassword) {
                                iconPassword = Icons.visibility_off;
                              } else {
                                iconPassword = Icons.visibility;
                              }
                            });
                          },
                        ),
                      ),
                      errorMsg: errorMsg,
                    ),
                    LightTextFieldsPassword(
                      title: 'Confirm Password',
                      controller: _confirmpasswordController,
                      prefixIcon: const Icon(Icons.lock),
                      obscurePassword: obscurePassword,
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: IconButton(
                          icon: Icon(
                            iconPassword,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                              if (obscurePassword) {
                                iconPassword = Icons.visibility_off;
                              } else {
                                iconPassword = Icons.visibility;
                              }
                            });
                          },
                        ),
                      ),
                      errorMsg: errorMsg,
                    ),
                    LightTextFieldsDate(
                        title: 'Date Of Birth',
                        controller: _dateofBirthController,
                        prefixIcon: const Icon(Icons.calendar_month)),
                    SizedBox(height: mediaQuery.height * 0.05),
                    Text(
                      'Select Your Gender',
                      style: TextStyle(
                        fontSize: mediaQuery.width * 0.055,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: mediaQuery.height * 0.02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GenderPicker(
                          title: 'Male',
                          iconData: Icons.male,
                          isSelected: selectedGender == 'Male',
                          onTap: () {
                            setState(() {
                              selectedGender = 'Male';
                            });
                          },
                        ),
                        GenderPicker(
                          title: 'Female',
                          iconData: Icons.female,
                          isSelected: selectedGender == 'Female',
                          onTap: () {
                            setState(() {
                              selectedGender = 'Female';
                            });
                          },
                        ),
                        GenderPicker(
                          title: 'Other',
                          iconData: Icons.transgender,
                          isSelected: selectedGender == 'Other',
                          onTap: () {
                            setState(() {
                              selectedGender = 'Other';
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: mediaQuery.height * 0.05),
                    WeightHeightPicker(
                      heightUnit: _heightUnit,
                      heightValue: _height,
                      onChangedHeight: (value) {
                        setState(() {
                          _height = value;
                        });
                      },
                      onChangedWeight: (value) {
                        setState(() {
                          _weight = value;
                        });
                      },
                      onUnitChangedHeight: (unit) {
                        setState(() {
                          _heightUnit = unit;
                          // Convert current height to the new unit
                          if (unit == 'cm') {
                            _height = (_height * 2.54)
                                .clamp(_minHeightCm, _maxHeightCm);
                          } else {
                            _height = (_height / 2.54)
                                .clamp(_minHeightIn, _maxHeightIn);
                          }
                        });
                      },
                      onUnitChangedWeight: (unit) {
                        setState(() {
                          _weightUnit = unit;
                          // Convert current weight to the new unit
                          if (unit == 'kg') {
                            _weight = (_weight / 2.20462)
                                .clamp(_minWeightKg, _maxWeightKg);
                          } else {
                            _weight = (_weight * 2.20462)
                                .clamp(_minWeightLbs, _maxWeightLbs);
                          }
                        });
                      },
                      weightUnit: _weightUnit,
                      weightValue: _weight,
                    ),
                    SizedBox(
                      height: mediaQuery.height * 0.05,
                    ),
                    SizedBox(
                        width: mediaQuery.width * 0.8,
                        child: LightShortButton(
                            onPress: () {
                              if (_formKey.currentState!.validate()) {
                                if (selectedGender != null) {
                                  if (_passwordController.text.trim() ==
                                      _confirmpasswordController.text.trim()) {
                                    MyUser myUser = MyUser.empty;
                                    myUser = myUser.copyith(
                                      email: _emailController.text.trim(),
                                      name: _nameController.text.trim(),
                                      createdAt: DateFormat('dd-MM-yyyy HH:mm')
                                          .format(DateTime.now()),
                                      dateOfBirth:
                                          _dateofBirthController.text.trim(),
                                      gender: selectedGender,
                                      heightUnit: _heightUnit,
                                      heightValue: _height,
                                      updatedAt: DateFormat('dd-MM-yyyy HH:mm')
                                          .format(DateTime.now()),
                                      weightUnit: _weightUnit,
                                      weightValue: _weight,
                                    );

                                    setState(() {
                                      context.read<SignUpBloc>().add(
                                          SignUpRequired(myUser,
                                              _passwordController.text));
                                    });
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        duration: const Duration(seconds: 5),
                                        content: Text(
                                          'Passwords do not match.',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .surface,
                                              fontSize:
                                                  mediaQuery.width * 0.045),
                                        ),
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      duration: const Duration(seconds: 5),
                                      content: Text(
                                        'Select a gender',
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surface,
                                            fontSize: mediaQuery.width * 0.045),
                                      ),
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            title: 'Sign Up')),
                    SizedBox(
                      height: mediaQuery.height * 0.03,
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(() => BlocProvider(
                              create: (context) => SignInBloc(
                                  userRepository: context
                                      .read<AuthenticationBloc>()
                                      .userRepository),
                              child: const LogInScreen(),
                            ));
                      },
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Already a member? Log in now',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: mediaQuery.width * 0.05,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
