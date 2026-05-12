import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/event_entity.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import '../bloc/event_bloc.dart';
import '../bloc/event_event.dart';
import '../bloc/event_state.dart';

class EventPage extends StatelessWidget {
  final EventEntity event;

  const EventPage({super.key, required this.event});

  bool _canManage(BuildContext context) {
    final profileState = context.read<ProfileBloc>().state;
    String? userId;
    List<String> roles = const [];
    if (profileState is ProfileLoaded) {
      userId = profileState.profile.id;
      roles = profileState.profile.roles ?? const [];
    } else if (profileState is ProfileUpdateSuccess) {
      userId = profileState.profile.id;
      roles = profileState.profile.roles ?? const [];
    }
    final isOwner = userId != null && userId == event.createdBy;
    final isAdmin = roles.contains('ROLE_ADMIN');
    return isOwner || isAdmin;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final canManage = _canManage(context);

    return BlocListener<EventBloc, EventState>(
      listener: (context, state) {
        if (state is EventDeleteSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Evento eliminado')),
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
          backgroundColor: colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Detalle del evento',
            style: TextStyle(color: colorScheme.onSurface),
          ),
          actions: [
            if (canManage)
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: colorScheme.onSurface),
                onSelected: (value) => _onMenuSelected(context, value),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined,
                            size: 20, color: colorScheme.onSurface),
                        const SizedBox(width: 12),
                        const Text('Editar'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline,
                            size: 20, color: colorScheme.error),
                        const SizedBox(width: 12),
                        Text(
                          'Eliminar',
                          style: TextStyle(color: colorScheme.error),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
        body: SafeArea(
          child: BlocBuilder<EventBloc, EventState>(
            builder: (context, state) {
              final isLoading = state is EventLoading;
              return Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(
                          icon: Icons.access_time,
                          label: _formatDate(event.date),
                        ),
                        const SizedBox(height: 8),
                        _InfoRow(
                          icon: Icons.location_on_outlined,
                          label: event.location.isEmpty
                              ? 'Sin ubicación'
                              : event.location,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Descripción',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          event.description.isEmpty
                              ? 'Sin descripción'
                              : event.description,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Invitados',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          event.recipientIds.isEmpty
                              ? 'Sin invitados'
                              : '${event.recipientIds.length} persona${event.recipientIds.length == 1 ? '' : 's'}',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isLoading)
                    Container(
                      color: colorScheme.surface.withValues(alpha: 0.5),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _onMenuSelected(BuildContext context, String value) {
    switch (value) {
      case 'edit':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Edición próximamente disponible')),
        );
        break;
      case 'delete':
        _confirmDelete(context);
        break;
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;
    final bloc = context.read<EventBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar evento'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este evento? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: colorScheme.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      bloc.add(DeleteEventRequested(event.id));
    }
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final hour = date.hour > 12
          ? date.hour - 12
          : (date.hour == 0 ? 12 : date.hour);
      final period = date.hour >= 12 ? 'PM' : 'AM';
      final minute = date.minute.toString().padLeft(2, '0');
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      return '$day/$month/${date.year}, $hour:$minute $period';
    } catch (_) {
      return isoDate;
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: colorScheme.onSurface.withValues(alpha: 0.7)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ),
      ],
    );
  }
}
