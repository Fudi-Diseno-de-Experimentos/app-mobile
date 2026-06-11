import 'package:app_mobile/core/network/cloudinary_config.dart';
import 'package:app_mobile/features/company/domain/entities/company_entity.dart';
import 'package:app_mobile/features/company/presentation/bloc/company_bloc.dart';
import 'package:app_mobile/features/company/presentation/bloc/company_event.dart';
import 'package:app_mobile/features/company/presentation/bloc/company_state.dart';
import 'package:app_mobile/shared/widgets/custom_text_field.dart';
import 'package:app_mobile/shared/widgets/image_upload_picker.dart';
import 'package:app_mobile/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CompanyEditPage extends StatefulWidget {
  final CompanyEntity company;

  const CompanyEditPage({super.key, required this.company});

  @override
  State<CompanyEditPage> createState() => _CompanyEditPageState();
}

class _CompanyEditPageState extends State<CompanyEditPage> {
  final _companyNameController = TextEditingController();
  final _rucController = TextEditingController();
  String? _uploadedIconUrl;

  @override
  void initState() {
    super.initState();
    _companyNameController.text = widget.company.name;
    _rucController.text = widget.company.ruc;
    _uploadedIconUrl = widget.company.iconUrl;
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _rucController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_companyNameController.text.isEmpty || _rucController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields')),
      );
      return;
    }

    context.read<CompanyBloc>().add(
          UpdateCompanyRequested(
            id: widget.company.id,
            ruc: _rucController.text,
            name: _companyNameController.text,
            iconUrl: _uploadedIconUrl,
            isActive: widget.company.isActive,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<CompanyBloc, CompanyState>(
      listener: (context, state) {
        if (state is CompanyUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Company updated successfully!')),
          );
          context.pop(true); // Return true to indicate reload is needed
        } else if (state is CompanyFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Company'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Company Details',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Modify the name, tax ID (RUC) or change the brand logo.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha:0.7),
                  ),
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  hintText: 'Company Name',
                  controller: _companyNameController,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  hintText: 'RUC (Tax ID)',
                  controller: _rucController,
                ),
                const SizedBox(height: 24),
                ImageUploadPicker(
                  imageType: ImageType.company,
                  initialImageUrl: _uploadedIconUrl,
                  onImageUploaded: (url) {
                    setState(() {
                      _uploadedIconUrl = url;
                    });
                  },
                ),
                const SizedBox(height: 40),
                BlocBuilder<CompanyBloc, CompanyState>(
                  builder: (context, state) {
                    return PrimaryButton(
                      text: 'Save Changes',
                      isLoading: state is CompanyLoading,
                      onPressed: _onSave,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
