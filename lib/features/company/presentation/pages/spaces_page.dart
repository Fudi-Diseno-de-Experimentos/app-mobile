import 'package:app_mobile/features/company/domain/entities/space_entity.dart';
import 'package:app_mobile/features/company/presentation/bloc/space_bloc.dart';
import 'package:app_mobile/features/company/presentation/bloc/space_event.dart';
import 'package:app_mobile/features/company/presentation/bloc/space_state.dart';
import 'package:app_mobile/features/company/presentation/widgets/space_form_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SpacesPage extends StatefulWidget {
  const SpacesPage({super.key});

  @override
  State<SpacesPage> createState() => _SpacesPageState();
}

class _SpacesPageState extends State<SpacesPage> {
  @override
  void initState() {
    super.initState();
    context.read<SpaceBloc>().add(const FetchSpaces());
  }

  Future<void> _openCreateSheet() async {
    final result = await showSpaceFormSheet(context);
    if (result == null || !mounted) return;
    context.read<SpaceBloc>().add(
          CreateSpaceRequested(
            name: result.name,
            description: result.description,
          ),
        );
  }

  Future<void> _openEditSheet(SpaceEntity space) async {
    final result = await showSpaceFormSheet(context, space: space);
    if (result == null || !mounted) return;
    context.read<SpaceBloc>().add(
          UpdateSpaceRequested(
            id: space.id,
            name: result.name,
            description: result.description,
          ),
        );
  }

  Future<void> _confirmDelete(SpaceEntity space) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete room'),
        content: Text('Delete "${space.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<SpaceBloc>().add(DeleteSpaceRequested(space.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Spaces')),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateSheet,
        backgroundColor: colorScheme.onSurface,
        child: Icon(Icons.add, color: colorScheme.surface),
      ),
      body: SafeArea(
        child: BlocConsumer<SpaceBloc, SpaceState>(
          listener: (context, state) {
            if (state is SpaceActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            } else if (state is SpaceError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: colorScheme.error,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is SpaceLoading || state is SpaceInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is SpacesLoaded) {
              if (state.spaces.isEmpty) {
                return _buildEmpty(colorScheme);
              }
              return RefreshIndicator(
                onRefresh: () async =>
                    context.read<SpaceBloc>().add(const FetchSpaces()),
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  itemCount: state.spaces.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) =>
                      _buildSpaceTile(state.spaces[index], colorScheme),
                ),
              );
            }
            // SpaceError with nothing loaded yet — offer a retry.
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state is SpaceError ? state.message : 'Something went wrong',
                    style: TextStyle(color: colorScheme.error),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<SpaceBloc>().add(const FetchSpaces()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmpty(ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.meeting_room_outlined,
              size: 56,
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No rooms yet',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap + to create your first space.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpaceTile(SpaceEntity space, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.secondary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.meeting_room_outlined, color: colorScheme.primary),
        ),
        title: Text(
          space.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: space.description != null && space.description!.isNotEmpty
            ? Text(
                space.description!,
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              )
            : null,
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: colorScheme.onSurface),
          onSelected: (value) {
            if (value == 'edit') _openEditSheet(space);
            if (value == 'delete') _confirmDelete(space);
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit_outlined, color: colorScheme.primary, size: 20),
                  const SizedBox(width: 12),
                  const Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, color: colorScheme.error, size: 20),
                  const SizedBox(width: 12),
                  Text('Delete', style: TextStyle(color: colorScheme.error)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
