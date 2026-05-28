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
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_event.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _onVerify() {
    context.read<IamBloc>().add(
      JoinCompanySubmitted(joinCode: _codeController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<IamBloc, IamState>(
      listener: (context, state) {
        if (state is IamJoinCompanySuccess) {
          // Success joining company, reload profile and proceed to home
          context.read<ProfileBloc>().add(ProfileLoadRequested());
          context.go('/home');
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
            Text(
              "Verify your company",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              "Please enter the join code provided by your company admin.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            CustomTextField(
              hintText: 'Enter 6-digit code',
              controller: _codeController,
            ),
            const SizedBox(height: 48),
            BlocBuilder<IamBloc, IamState>(
              builder: (context, state) {
                return PrimaryButton(
                  text: 'Join',
                  isLoading: state is IamLoading,
                  onPressed: _onVerify,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
