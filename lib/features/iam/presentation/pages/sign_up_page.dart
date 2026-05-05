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

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _lastnameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRegister() {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    context.read<IamBloc>().add(
      SignUpSubmitted(
        username: _usernameController.text,
        password: _passwordController.text,
        name: _nameController.text,
        lastname: _lastnameController.text,
        email: _emailController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<IamBloc, IamState>(
      listener: (context, state) {
        if (state is IamSignUpSuccess) {
          // After successful signup, user can sign in
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account created. Please sign in.')),
          );
          context.pop(); // back to login
        } else if (state is IamError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: AuthScaffold(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const LogoHeader(),
              const SizedBox(height: 32),
              CustomTextField(
                hintText: 'First Name',
                controller: _nameController,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                hintText: 'Last Name',
                controller: _lastnameController,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                hintText: 'Username',
                controller: _usernameController,
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
              CustomTextField(
                hintText: 'Confirm Password',
                isPassword: true,
                controller: _confirmPasswordController,
              ),
              const SizedBox(height: 32),
              BlocBuilder<IamBloc, IamState>(
                builder: (context, state) {
                  return PrimaryButton(
                    text: 'Sign Up',
                    isLoading: state is IamLoading,
                    onPressed: _onRegister,
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Text(
                      "Sign in",
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
      ),
    );
  }
}
