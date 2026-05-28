import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../app/di.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/profile/presentation/bloc/profile_state.dart';
import '../../features/profile/presentation/bloc/profile_event.dart';
import '../../features/announcements/domain/repositories/announcement_repository.dart';
import '../../features/events/domain/repositories/event_repository.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';

class MainLayout extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainLayout({super.key, required this.navigationShell});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  @override
  void initState() {
    super.initState();
    final profileBloc = context.read<ProfileBloc>();
    if (profileBloc.state is ProfileInitial) {
      profileBloc.add(ProfileLoadRequested());
    }
    _preFetchData();
  }

  void _preFetchData() async {
    // Background pre-fetching of data to populate repositories caches
    if (sl.isRegistered<AnnouncementRepository>()) {
      sl<AnnouncementRepository>().getAnnouncements();
    }
    if (sl.isRegistered<EventRepository>()) {
      sl<EventRepository>().getEvents();
    }
    if (sl.isRegistered<ChatRepository>()) {
      sl<ChatRepository>().getMyConversations();
    }

    final profileState = context.read<ProfileBloc>().state;
    if (profileState is ProfileLoaded) {
      if (sl.isRegistered<ChatRepository>()) {
        sl<ChatRepository>().getMyGroups(profileState.profile.id);
      }
    } else {
      if (sl.isRegistered<ProfileRepository>() && sl.isRegistered<ChatRepository>()) {
        final profileResult = await sl<ProfileRepository>().getProfile();
        profileResult.fold(
          (_) {},
          (profile) {
            sl<ChatRepository>().getMyGroups(profile.id);
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded) {
          if (state.profile.companyId == null || state.profile.companyId!.isEmpty) {
            context.go('/join-company');
          }
        }
      },
      child: Scaffold(
        body: widget.navigationShell,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: widget.navigationShell.currentIndex,
          onTap: (index) {
            widget.navigationShell.goBranch(
              index,
              initialLocation: index == widget.navigationShell.currentIndex,
            );
          },
          type: BottomNavigationBarType.fixed,
          items: [
            _buildNavItem('assets/icons/home-icon.svg', 'Home', 0),
            _buildNavItem('assets/icons/file-icon.svg', 'Files', 1),
            _buildNavItem('assets/icons/message-square-icon.svg', 'Messages', 2),
            _buildNavItem('assets/icons/user-icon.svg', 'Profile', 3),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(String asset, String label, int index) {
    return BottomNavigationBarItem(
      icon: SvgPicture.asset(
        asset,
        width: 24,
        height: 24,
        colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
      ),
      activeIcon: SvgPicture.asset(
        asset,
        width: 24,
        height: 24,
        colorFilter: const ColorFilter.mode(Colors.blue, BlendMode.srcIn),
      ),
      label: label,
    );
  }
}
