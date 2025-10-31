import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';  
import '../../../authentication/presentation/pages/login_page.dart';
import '../bloc/meter_reading_bloc.dart';
import '../bloc/meter_reading_event.dart';  
import '../bloc/meter_reading_state.dart';  
import 'qr_scanner_page.dart';
import 'settings_page.dart';
import 'tenant_details_page.dart';
import '../widgets/app_bottom_nav.dart'; 

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load tenants when page loads
    context.read<MeterReadingBloc>().add(AllTenantsRequested());
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      // Show QR Scanner bottom sheet
      showQRScannerBottomSheet(context);
      // Reset selection back to home
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() {
            _selectedIndex = 0;
          });
        }
      });
    } else if (index == 2) {
      // Navigate to Settings
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SettingsPage()),
      ).then((_) {
        // Reset selection when coming back
        setState(() {
          _selectedIndex = 0;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
  backgroundColor: const Color(0xFFEFF3F8),
  elevation: 0,
  toolbarHeight: 100,
  leadingWidth: 120,
  leading: Padding(
    padding: const EdgeInsets.only(left: 2),
    child: Image.asset(
      'assets/icon/logo_aquaflow.png',
      width: 100,
      fit: BoxFit.contain,
    ),
  ),
  titleSpacing: -30,
  title: BlocBuilder<AuthBloc, AuthState>(
    builder: (context, state) {
      String userName = 'User';
      if (state is AuthAuthenticated) {
        userName = state.user.name;
      }
      return Text(
        'Welcome, $userName!',
        style: const TextStyle(
          color: AppTheme.textDark,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      );
    },
  ),
),

        body: RefreshIndicator(
          onRefresh: () async {
            context.read<MeterReadingBloc>().add(AllTenantsRequested());
          },
          child: Column(
            children: [
              // Section Title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Activity History',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                ),
              ),

              // Tenants List
              Expanded(
                child: BlocBuilder<MeterReadingBloc, MeterReadingState>(
                  builder: (context, state) {
                    if (state is MeterReadingLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (state is TenantsLoaded) {
                      if (state.tenants.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 64,
                                color: AppTheme.textLight.withAlpha(128),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No tenants found',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppTheme.textLight.withAlpha(179),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: state.tenants.length,
                        itemBuilder: (context, index) {
                          final tenant = state.tenants[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              onTap: () {
                                // Navigate to Tenant Details Page
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TenantDetailsPage(
                                      tenant: tenant,
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    // Avatar
                                    CircleAvatar(
                                      radius: 28,
                                      backgroundColor:
                                          AppTheme.primaryBlue.withAlpha(26),
                                      child: const Icon(
                                        Icons.water_drop,
                                        color: AppTheme.primaryBlue,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 16),

                                    // Tenant Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            tenant.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: AppTheme.textDark,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.location_on,
                                                size: 14,
                                                color: AppTheme.textLight,
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  tenant.location,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    color: AppTheme.textLight,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.email,
                                                size: 14,
                                                color: AppTheme.textLight,
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  tenant.email,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: AppTheme.textLight,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    } else if (state is MeterReadingError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 64,
                              color: AppTheme.errorRed,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppTheme.textLight,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                context
                                    .read<MeterReadingBloc>()
                                    .add(AllTenantsRequested());
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    // Initial state - show loading
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: AppBottomNav(
          currentIndex: _selectedIndex,
          onTap: _onBottomNavTap,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            showQRScannerBottomSheet(context);
          },
          icon: const Icon(Icons.qr_code_scanner),
          label: const Text('Scan QR'),
          backgroundColor: AppTheme.primaryBlue,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}