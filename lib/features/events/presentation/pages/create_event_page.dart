import 'package:app_mobile/features/events/domain/entities/event_entity.dart';
import 'package:app_mobile/features/events/presentation/bloc/event_bloc.dart';
import 'package:app_mobile/features/events/presentation/bloc/event_event.dart';
import 'package:app_mobile/features/events/presentation/bloc/event_state.dart';
import 'package:app_mobile/features/profile/domain/entities/profile_entity.dart';
import 'package:app_mobile/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:app_mobile/features/profile/presentation/bloc/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CreateEventPage extends StatefulWidget {
  final EventEntity? event;

  const CreateEventPage({super.key, this.event});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  List<ProfileEntity> _members = [];
  final Set<String> _selectedRecipientIds = {};

  bool get _isEditMode => widget.event != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.event;
    if (existing != null) {
      _titleController.text = existing.title;
      _descriptionController.text = existing.description;
      _locationController.text = existing.location;
      _selectedRecipientIds.addAll(existing.recipientIds);
      try {
        final parsed = DateTime.parse(existing.date);
        _selectedDate = DateTime(parsed.year, parsed.month, parsed.day);
        _selectedTime = TimeOfDay(hour: parsed.hour, minute: parsed.minute);
      } catch (_) {}
    }
    final profileState = context.read<ProfileBloc>().state;
    final companyId = profileState.profileOrNull?.companyId;
    if (companyId != null) {
      context.read<EventBloc>().add(FetchCompanyMembers(companyId));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final initial = _selectedDate ?? now;
    final firstDate =
        _selectedDate != null && _selectedDate!.isBefore(today)
            ? _selectedDate!
            : today;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: colorScheme.primary,
              onPrimary: colorScheme.onPrimary,
              onSurface: colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) setState(() => _selectedDate = pickedDate);
  }

  Future<void> _selectTime() async {
    final colorScheme = Theme.of(context).colorScheme;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: colorScheme.primary,
              onPrimary: colorScheme.onPrimary,
              onSurface: colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedTime != null) setState(() => _selectedTime = pickedTime);
  }

  void _submitForm() {
    final colorScheme = Theme.of(context).colorScheme;
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please pick a date for the event'),
          backgroundColor: colorScheme.error,
        ),
      );
      return;
    }
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please pick a time for the event'),
          backgroundColor: colorScheme.error,
        ),
      );
      return;
    }

    final scheduled = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final existing = widget.event;
    if (existing != null) {
      context.read<EventBloc>().add(
            UpdateEventRequested(
              id: existing.id,
              title: _titleController.text,
              description: _descriptionController.text,
              date: scheduled.toIso8601String(),
              location: _locationController.text,
              recipientIds: _selectedRecipientIds.toList(),
            ),
          );
      return;
    }

    final profileState = context.read<ProfileBloc>().state;
    final userId =
        profileState.profileOrNull?.id ?? '00000000-0000-0000-0000-000000000000';

    context.read<EventBloc>().add(
          CreateEventRequested(
            title: _titleController.text,
            description: _descriptionController.text,
            date: scheduled.toIso8601String(),
            location: _locationController.text,
            createdBy: userId,
            recipientIds: _selectedRecipientIds.toList(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final formattedDate = _selectedDate == null
        ? 'No date chosen'
        : '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';

    final formattedTime =
        _selectedTime == null ? 'No time chosen' : _selectedTime!.format(context);

    return BlocListener<EventBloc, EventState>(
      listener: (context, state) {
        if (state is EventMembersLoaded) {
          setState(() => _members = state.members);
        } else if (state is EventCreateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Event created successfully!')),
          );
          context.pop();
        } else if (state is EventUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Event updated successfully!')),
          );
          context.pop();
        } else if (state is EventError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: colorScheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: Text(
            _isEditMode ? 'Edit Event' : 'Create Event',
            style: TextStyle(color: colorScheme.onSurface),
          ),
          backgroundColor: colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isEditMode ? 'Edit Event Details' : 'New Event Details',
                    style: textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isEditMode
                        ? 'Update the event details below and save your changes.'
                        : 'Establish a new official company event. Only Admins and Managers can perform this action.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Title
                  _buildLabel('Event Title', colorScheme),
                  TextFormField(
                    controller: _titleController,
                    style: TextStyle(color: colorScheme.onSurface),
                    decoration: _buildInputDecoration('Enter event title', colorScheme),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Please enter a title' : null,
                  ),
                  const SizedBox(height: 24),

                  // Description
                  _buildLabel('Description', colorScheme),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    style: TextStyle(color: colorScheme.onSurface),
                    decoration:
                        _buildInputDecoration('Describe the event details...', colorScheme),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Please enter a description' : null,
                  ),
                  const SizedBox(height: 24),

                  // Date & Time
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Date', colorScheme),
                            _buildPickerButton(
                              icon: Icons.calendar_today,
                              label: formattedDate,
                              hasValue: _selectedDate != null,
                              onTap: _selectDate,
                              colorScheme: colorScheme,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Time', colorScheme),
                            _buildPickerButton(
                              icon: Icons.access_time,
                              label: formattedTime,
                              hasValue: _selectedTime != null,
                              onTap: _selectTime,
                              colorScheme: colorScheme,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Location
                  _buildLabel('Location', colorScheme),
                  TextFormField(
                    controller: _locationController,
                    style: TextStyle(color: colorScheme.onSurface),
                    decoration: _buildInputDecoration(
                        'e.g. Conference Room A, or Zoom', colorScheme),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Please enter a location' : null,
                  ),
                  const SizedBox(height: 24),

                  // Recipient picker
                  _buildMemberPickerSection(colorScheme, textTheme),
                  const SizedBox(height: 48),

                  // Submit
                  BlocBuilder<EventBloc, EventState>(
                    builder: (context, state) {
                      final isLoading = state is EventLoading;
                      return SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.onSurface,
                            foregroundColor: colorScheme.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colorScheme.surface,
                                  ),
                                )
                              : Text(
                                  _isEditMode ? 'Save Changes' : 'Create Event',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMemberPickerSection(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildLabel('Invite Members', colorScheme),
            ),
            if (_members.isNotEmpty)
              Text(
                '${_selectedRecipientIds.length} selected',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        BlocBuilder<EventBloc, EventState>(
          builder: (context, state) {
            if (state is EventLoading && _members.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: CircularProgressIndicator(color: colorScheme.onSurface),
                ),
              );
            }

            if (_members.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'No members found for your organization.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              );
            }

            return Column(
              children: _members.map((member) {
                final isSelected = _selectedRecipientIds.contains(member.id);
                final initials =
                    '${member.name.isNotEmpty ? member.name[0] : ''}${member.lastname.isNotEmpty ? member.lastname[0] : ''}'
                        .toUpperCase();

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primary.withValues(alpha: 0.08)
                        : colorScheme.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected
                        ? Border.all(
                            color: colorScheme.primary.withValues(alpha: 0.4),
                          )
                        : null,
                  ),
                  child: CheckboxListTile(
                    value: isSelected,
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          _selectedRecipientIds.add(member.id);
                        } else {
                          _selectedRecipientIds.remove(member.id);
                        }
                      });
                    },
                    secondary: CircleAvatar(
                      radius: 20,
                      backgroundColor: colorScheme.secondary.withValues(alpha: 0.3),
                      backgroundImage: member.avatarUrl != null &&
                              member.avatarUrl!.isNotEmpty
                          ? NetworkImage(member.avatarUrl!)
                          : null,
                      child: member.avatarUrl == null || member.avatarUrl!.isEmpty
                          ? Text(
                              initials,
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          : null,
                    ),
                    title: Text(
                      '${member.name} ${member.lastname}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      member.email,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    activeColor: colorScheme.primary,
                    checkColor: colorScheme.onPrimary,
                    controlAffinity: ListTileControlAffinity.trailing,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLabel(String text, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPickerButton({
    required IconData icon,
    required String label,
    required bool hasValue,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: colorScheme.secondary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: colorScheme.onSurface),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: hasValue
                      ? colorScheme.onSurface
                      : colorScheme.onSurface.withValues(alpha: 0.4),
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint, ColorScheme colorScheme) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4)),
      filled: true,
      fillColor: colorScheme.secondary.withValues(alpha: 0.1),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),
      errorStyle: TextStyle(color: colorScheme.error),
    );
  }
}
