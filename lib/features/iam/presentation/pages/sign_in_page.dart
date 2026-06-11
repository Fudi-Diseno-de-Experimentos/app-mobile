import 'package:app_mobile/features/iam/presentation/bloc/iam_bloc.dart';
import 'package:app_mobile/features/iam/presentation/bloc/iam_event.dart';
import 'package:app_mobile/features/iam/presentation/bloc/iam_state.dart';
import 'package:app_mobile/features/iam/presentation/widgets/auth_scaffold.dart';
import 'package:app_mobile/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:app_mobile/features/profile/presentation/bloc/profile_event.dart';
import 'package:app_mobile/shared/widgets/custom_text_field.dart';
import 'package:app_mobile/shared/widgets/logo_header.dart';
import 'package:app_mobile/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSignIn() {
    context.read<IamBloc>().add(
      SignInSubmitted(
        username: _usernameController.text,
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<IamBloc, IamState>(
      listener: (context, state) {
        if (state is IamSignInSuccess) {
          // Immediately load profile for the new user
          context.read<ProfileBloc>().add(ProfileLoadRequested());
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
              hintText: 'User Name',
              controller: _usernameController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              hintText: 'Password',
              isPassword: true,
              controller: _passwordController,
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
                  child: Text(
                    'Sign up now',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
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
