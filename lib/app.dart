import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:user_repository/user_repository.dart';
import 'package:vitality/authentication.dart';
import 'package:vitality/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:vitality/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:vitality/themes/light_mode.dart';

class MainApp extends StatelessWidget {
  final UserRepository userRepository;
  final String apiKey;
  const MainApp(this.userRepository, this.apiKey, {super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(providers: [
      RepositoryProvider<AuthenticationBloc>(
          create: (_) =>
              AuthenticationBloc(myUserRepository: userRepository)),
      RepositoryProvider<SignInBloc>(
          create: (_) =>
              SignInBloc(userRepository: context.read<AuthenticationBloc>().userRepository))
    ], child: GetMaterialApp(
      theme: lightMode,
      debugShowCheckedModeBanner: false,
      title: 'Vitality',
      home: const Authentication(apiKey: String.fromEnvironment('GEMINI_API_KEY'),),
      // routes: {
      //   '/sign_up_screen': (context) => const SignUpScreen(),
      //   '/log_in_screen': (context) => const LogInScreen(),
      // }
      )
    );
  }
}
