import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../widgets/auth_scaffold.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/logo_header.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../bloc/iam_bloc.dart';
import '../bloc/iam_event.dart';
import '../bloc/iam_state.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSignIn() {
    context.read<IamBloc>().add(
      SignInSubmitted(
        username: _emailController.text,
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<IamBloc, IamState>(
      listener: (context, state) {
        if (state is IamSignInSuccess) {
          if (state.user.companyId == null || state.user.companyId!.isEmpty) {
            context.go('/join-company');
          } else {
            context.go('/home');
          }
        } else if (state is IamError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: AuthScaffold(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LogoHeader(),
            const SizedBox(height: 64),
            CustomTextField(
              hintText: 'Enter your email',
              controller: _emailController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              hintText: 'Password',
              isPassword: true,
              controller: _passwordController,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  'Forgot password?',
                  style: TextStyle(color: Color(0xFF007AFF), fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 32),
            BlocBuilder<IamBloc, IamState>(
              builder: (context, state) {
                return PrimaryButton(
                  text: 'Sign in',
                  isLoading: state is IamLoading,
                  onPressed: _onSignIn,
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account? ",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                GestureDetector(
                  onTap: () => context.push('/register'),
                  child: const Text(
                    "Sign up now",
                    style: TextStyle(
                      color: Color(0xFF007AFF),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
