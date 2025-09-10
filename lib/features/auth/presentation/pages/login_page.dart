import 'package:blog_app/core/common/utils/show_dialog.dart';
import 'package:blog_app/core/common/widgets/loader.dart';
import 'package:blog_app/features/auth/presentation/bloc/auth_bloc.dart';
//import 'package:blog_app/features/blog/presentation/pages/blog_page.dart';
import 'package:blog_app/features/auth/presentation/widgets/gradient_button_widget.dart';
import 'package:blog_app/features/auth/presentation/widgets/textfield_widget.dart';
import 'package:blog_app/features/blog/presentation/pages/blog_page.dart';
import 'package:flutter/material.dart';
import 'package:blog_app/core/color_pallate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'signup_page.dart';

class SignInPage extends StatefulWidget {
  static route() => MaterialPageRoute(builder: (context) => const SignInPage());
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void login() {
    if (formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthSignIn(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            showSnackbar(context, state.message!);
          } else if (state is AuthLogInSuccess) {
            Navigator.pushAndRemoveUntil(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const BlogPage(),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
              (route) => false,
            );
            emailController.clear();
            passwordController.clear();
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Loader();
          }

          return OrientationBuilder(
            builder: (context, orientation) {
              final content = Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        "Sign In.",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextfieldWidget(
                        hintText: "email",
                        controller: emailController,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextfieldWidget(
                        hintText: "password",
                        controller: passwordController,
                        isPassword: true,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: AuthGradientButton(
                        data: "Sign In",
                        onPressed: login,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignupPage(),
                                ),
                              );
                            },
                            child: Text(
                              "Sign Up",
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppPallete.gradient1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );

              if (orientation == Orientation.portrait) {
                return SafeArea(
                  child: Center(child: SingleChildScrollView(child: content)),
                );
              } else {
                return SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Center(child: content),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
