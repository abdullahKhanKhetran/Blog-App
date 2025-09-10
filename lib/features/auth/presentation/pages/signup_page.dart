import 'package:blog_app/core/color_pallate.dart';
import 'package:blog_app/core/common/widgets/loader.dart';
import 'package:blog_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:blog_app/features/auth/presentation/widgets/gradient_button_widget.dart';
import 'package:blog_app/features/auth/presentation/widgets/textfield_widget.dart';
import 'package:flutter/material.dart';
import 'package:blog_app/features/auth/presentation/pages/login_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blog_app/core/common/utils/show_dialog.dart';

class SignupPage extends StatefulWidget {
  static route() => MaterialPageRoute(builder: (context) => const SignupPage());
  const SignupPage({super.key});

  // This widget is the root of your application.
  @override
  State<SignupPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignupPage> {
  final formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void signUp() {
    if (formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthSignUp(
          email: emailController.text.trim().toLowerCase(),
          name: nameController.text.trim().toLowerCase(),
          password: passwordController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        Widget contentForm() => Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  "Sign Up.",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextfieldWidget(
                  hintText: "name",
                  controller: nameController,
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
                child: AuthGradientButton(data: "Sign Up", onPressed: signUp),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignInPage(),
                          ),
                        );
                      },
                      child: Text(
                        "Sign In",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppPallete.gradient2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

        final scaffoldBody = BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthFailure) {
              showSnackbar(context, "${state.message}");
            } else if (state is AuthSignUpSuccess) {
              Navigator.pushAndRemoveUntil(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const SignInPage(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
                (route) => false,
              );
              nameController.clear();
              emailController.clear();
              passwordController.clear();
            }
          },
          builder: (context, state) {
            if (state is AuthLoading) return const Loader();
            if (orientation == Orientation.portrait) {
              return Center(child: contentForm());
            } else {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Center(child: contentForm()),
              );
            }
          },
        );

        return Scaffold(
          appBar: orientation == Orientation.portrait ? AppBar() : null,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: scaffoldBody,
            ),
          ),
        );
      },
    );
  }
}
