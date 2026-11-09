import 'package:flutter/material.dart';
import '../models/waste_request.dart';
import '../screens/add_ewaste_screen.dart';
import '../screens/home_dashboard_screen.dart';
import '../screens/my_requests_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/request_details_screen.dart';
import '../theme/app_theme.dart';

class ResponsiveLayout extends StatefulWidget {
  const ResponsiveLayout({super.key});

  @override
  State<ResponsiveLayout> createState() => _ResponsiveLayoutState();
}

class _ResponsiveLayoutState extends State<ResponsiveLayout> {
  int _selectedIndex = 0;
  DeviceCategory? _preselectedCategory;
  WasteRequest? _activeDetailRequest;

  void _onNavigate(int index, {DeviceCategory? category}) {
    setState(() {
      _activeDetailRequest = null;
      _selectedIndex = index;
      if (category != null) {
        _preselectedCategory = category;
      }
    });
  }

  void _openRequestDetails(WasteRequest request) {
    setState(() {
      _activeDetailRequest = request;
    });
  }

  void _closeRequestDetails() {
    setState(() {
      _activeDetailRequest = null;
    });
  }

  Widget _buildCurrentScreen() {
    if (_activeDetailRequest != null) {
      return RequestDetailsScreen(
        request: _activeDetailRequest!,
        onBack: _closeRequestDetails,
      );
    }

    switch (_selectedIndex) {
      case 0:
        return HomeDashboardScreen(
          onNavigate: (index, {category}) => _onNavigate(index, category: category),
          onOpenDetails: _openRequestDetails,
        );
      case 1:
        return AddEWasteScreen(
          initialCategory: _preselectedCategory,
          onRequestCreated: (req) {
            _onNavigate(2);
          },
          onNavigateToTab: (index) => _onNavigate(index),
        );
      case 2:
        return MyRequestsScreen(
          onOpenDetails: _openRequestDetails,
          onNavigateToTab: (index) => _onNavigate(index),
        );
      case 3:
        return ProfileScreen(
          onNavigateToTab: (index) => _onNavigate(index),
        );
      default:
        return HomeDashboardScreen(
          onNavigate: (index, {category}) => _onNavigate(index, category: category),
          onOpenDetails: _openRequestDetails,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 640;
        final isDesktop = constraints.maxWidth >= 1024;

        if (isMobile) {
          // Mobile layout: Bottom Navigation Bar
          return Scaffold(
            body: _buildCurrentScreen(),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) => _onNavigate(index),
              indicatorColor: AppTheme.primaryGreen.withValues(alpha: 0.15),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded, color: AppTheme.primaryGreen),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.add_circle_outline_rounded),
                  selectedIcon: Icon(Icons.add_circle_rounded, color: AppTheme.primaryGreen),
                  label: 'Add E-Waste',
                ),
                NavigationDestination(
                  icon: Icon(Icons.inventory_2_outlined),
                  selectedIcon: Icon(Icons.inventory_2_rounded, color: AppTheme.primaryGreen),
                  label: 'My Requests',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded, color: AppTheme.primaryGreen),
                  label: 'Profile',
                ),
              ],
            ),
          );
        }

        // Tablet & Desktop layout: NavigationRail on left
        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) => _onNavigate(index),
                extended: isDesktop,
                minWidth: 72,
                minExtendedWidth: 220,
                backgroundColor: Colors.white,
                indicatorColor: AppTheme.primaryGreen.withValues(alpha: 0.15),
                leading: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.recycling_rounded,
                          color: AppTheme.primaryGreen,
                          size: 26,
                        ),
                      ),
                      if (isDesktop) ...[
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'EcoCollect',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primaryGreen,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              'E-Waste Logistics',
                              style: TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home_rounded, color: AppTheme.primaryGreen),
                    label: Text('Home Dashboard'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.add_circle_outline_rounded),
                    selectedIcon: Icon(Icons.add_circle_rounded, color: AppTheme.primaryGreen),
                    label: Text('Add E-Waste'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.inventory_2_outlined),
                    selectedIcon: Icon(Icons.inventory_2_rounded, color: AppTheme.primaryGreen),
                    label: Text('My Requests'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.person_outline_rounded),
                    selectedIcon: Icon(Icons.person_rounded, color: AppTheme.primaryGreen),
                    label: Text('Profile & Impact'),
                  ),
                ],
                trailing: isDesktop
                    ? Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 14),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.lightGreen,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.accentGreen.withValues(alpha: 0.2)),
                              ),
                              child: const Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.shield_outlined, size: 14, color: AppTheme.primaryGreen),
                                      SizedBox(width: 6),
                                      Text(
                                        'Verified Prototype',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.primaryGreen,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Safe local data storage',
                                    style: TextStyle(fontSize: 10, color: Color(0xFF2E3D31)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    : null,
              ),
              const VerticalDivider(thickness: 1, width: 1, color: Color(0xFFE2E8E3)),
              Expanded(
                child: _buildCurrentScreen(),
              ),
            ],
          ),
        );
      },
    );
  }
}
