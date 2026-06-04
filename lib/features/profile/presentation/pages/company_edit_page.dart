import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/image_upload_picker.dart';
import '../../../../core/network/cloudinary_config.dart';
import '../../../company/domain/entities/company_entity.dart';
import '../../../company/presentation/bloc/company_bloc.dart';
import '../../../company/presentation/bloc/company_event.dart';
import '../../../company/presentation/bloc/company_state.dart';

class CompanyEditPage extends StatefulWidget {
  final CompanyEntity company;

  const CompanyEditPage({super.key, required this.company});

  @override
  State<CompanyEditPage> createState() => _CompanyEditPageState();
}

class _CompanyEditPageState extends State<CompanyEditPage> {
  final _nombreController = TextEditingController();
  final _rucController = TextEditingController();
  String? _uploadedIconUrl;

  @override
  void initState() {
    super.initState();
    _nombreController.text = widget.company.nombre;
    _rucController.text = widget.company.ruc;
    _uploadedIconUrl = widget.company.iconUrl;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _rucController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_nombreController.text.isEmpty || _rucController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields')),
      );
      return;
    }

    context.read<CompanyBloc>().add(
          UpdateCompanyRequested(
            id: widget.company.id,
            ruc: _rucController.text,
            nombre: _nombreController.text,
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
                  "Edit Company Details",
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Modify the name, tax ID (RUC) or change the brand logo.",
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  hintText: 'Company Name',
                  controller: _nombreController,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  hintText: 'RUC (Tax ID)',
                  controller: _rucController,
                ),
                const SizedBox(height: 24),
                ImageUploadPicker(
                  imageType: ImageType.announcement,
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
