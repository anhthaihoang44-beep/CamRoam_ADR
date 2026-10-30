import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/live/data/models/webcam_model.dart';
import '../../features/live/presentation/screens/live_screen.dart';
import '../../features/live/presentation/screens/global_map_screen.dart';
import '../../features/live/presentation/screens/webcam_player_screen.dart';
import '../../features/roam/presentation/screens/roam_screen.dart';
import '../../features/roam/presentation/screens/panorama_360_screen.dart';
import '../../features/roam/presentation/screens/earth_3d_screen.dart';
import '../../features/roam/presentation/screens/passport_screen.dart';
import '../../features/tools/presentation/screens/tools_screen.dart';
import '../../features/tools/presentation/screens/gps_camera_screen.dart';
import '../../features/tools/presentation/screens/compass_screen.dart';
import '../../features/tools/presentation/screens/distance_screen.dart';
import '../../features/tools/presentation/screens/traffic_map_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/settings/presentation/screens/privacy_screen.dart';
import '../../features/roam/data/models/landmark_model.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/live',
    routes: [
      // Shell for bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return _MainScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: '/live',
            pageBuilder: (context, state) => const NoTransitionPage(child: LiveScreen()),
          ),
          GoRoute(
            path: '/roam',
            pageBuilder: (context, state) => const NoTransitionPage(child: RoamScreen()),
          ),
          GoRoute(
            path: '/tools',
            pageBuilder: (context, state) => const NoTransitionPage(child: ToolsScreen()),
          ),
        ],
      ),

      // Full-screen routes (no bottom nav)
      GoRoute(
        path: '/map-webcams',
        builder: (context, state) => const GlobalMapScreen(),
      ),
      GoRoute(
        path: '/live-player',
        builder: (context, state) {
          final cam = (state.extra as WebcamModel?) ??
              const WebcamModel(
                id: 'cam-01',
                title: 'Shibuya Crossing Live',
                city: 'Tokyo',
                country: 'Japan',
                latitude: 35.6595,
                longitude: 139.7004,
                thumbnailUrl:
                    'https://images.unsplash.com/photo-1542051841857-5f90071e7989?w=1200&auto=format&fit=crop&q=80',
                streamUrl: 'https://www.youtube.com/watch?v=HpdO5Kq3o7Y',
                category: 'Skyline',
                isHot: true,
                timezone: 'Asia/Tokyo',
              );
          return WebcamPlayerScreen(webcam: cam);
        },
      ),
      GoRoute(
        path: '/panorama',
        builder: (context, state) {
          final lm = state.extra as LandmarkModel?;
          return Panorama360Screen(landmark: lm);
        },
      ),
      GoRoute(
        path: '/earth3d',
        builder: (context, state) => const Earth3dScreen(),
      ),
      GoRoute(
        path: '/passport',
        builder: (context, state) => const PassportScreen(),
      ),
      GoRoute(
        path: '/gps-camera',
        builder: (context, state) => const GpsCameraScreen(),
      ),
      GoRoute(
        path: '/compass',
        builder: (context, state) => const CompassScreen(),
      ),
      GoRoute(
        path: '/distance',
        builder: (context, state) => const DistanceScreen(),
      ),
      GoRoute(
        path: '/traffic',
        builder: (context, state) => const TrafficMapScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/privacy',
        builder: (context, state) => const PrivacyScreen(),
      ),
    ],
  );
}

class _MainScaffold extends StatefulWidget {
  final Widget child;
  const _MainScaffold({required this.child});

  @override
  State<_MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<_MainScaffold> {
  int _currentIndex = 0;

  final List<String> _routes = ['/live', '/roam', '/tools'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        height: 68,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
          context.go(_routes[index]);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.videocam_outlined),
            selectedIcon: Icon(Icons.videocam_rounded),
            label: 'Live',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore_rounded),
            label: 'Roam',
          ),
          NavigationDestination(
            icon: Icon(Icons.construction_outlined),
            selectedIcon: Icon(Icons.construction_rounded),
            label: 'Tools',
          ),
        ],
      ),
    );
  }
}

