import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitality/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:vitality/components/button.dart';
import 'package:vitality/components/textfields.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();

  String? errorMsg;
  bool obscurePassword = true;
  IconData iconPassword = Icons.visibility_off;
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
                  'Log in',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: mediaQuery.width * 0.08,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
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
                SizedBox(
                  height: mediaQuery.height * 0.01,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Forgot password?',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: mediaQuery.width * 0.05,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                SizedBox(
                  height: mediaQuery.height * 0.05,
                ),
                SizedBox(
                    width: mediaQuery.width * 0.8,
                    child: BlocListener<SignInBloc, SignInState>(
                      listener: (context, state) {
                        if (state is SignInFailure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            duration: const Duration(seconds: 5),
                            content: Text(
                              state.errorMessage,
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.surface),
                            ),
                            backgroundColor:
                                Theme.of(context).colorScheme.error,
                          ),
                        );
                      }
                      if (state is SignInSuccess) {
                        Navigator.pop(context);
                      }
                      },
                      child: LightShortButton(onPress: () {
                        if (_formKey.currentState!.validate()) {
                            context.read<SignInBloc>().add(SignInRequired(
                                _emailController.text.trim(),
                                _passwordController.text.trim()));
                            
                          }
                      }, title: 'Log In'),
                    )),
                SizedBox(
                  height: mediaQuery.height * 0.03,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Not a member? Register now',
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
  }
}
