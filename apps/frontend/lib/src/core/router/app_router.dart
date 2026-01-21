import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/verify_otp_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/company_selection_page.dart';
import '../../features/dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../features/dashboard/presentation/pages/admin_dashboard_page.dart';
import '../../features/dashboard/presentation/pages/site_coordinator_dashboard_page.dart';
import '../../features/dashboard/presentation/pages/supervisor_dashboard_page.dart';
import '../../features/dashboard/presentation/pages/technician_dashboard_page.dart';
import '../../features/dashboard/presentation/pages/tenant_dashboard_page.dart';
import '../../features/dashboard/presentation/pages/super_admin_dashboard_page.dart';
import '../../features/maintenance_ticket/presentation/pages/admin/maintenance_ticket_list_page.dart';
import '../../features/maintenance_ticket/presentation/pages/admin/maintenance_ticket_detail_page_enhanced.dart';
import '../../features/maintenance_ticket/presentation/pages/admin/admin_ticket_create_ai_page.dart';
import '../../features/maintenance_ticket/presentation/pages/technician/technician_ticket_detail_page.dart';
import '../../features/maintenance_ticket/presentation/pages/tenant/tenant_complaint_create_ai_page.dart';
import '../../features/maintenance_ticket/presentation/pages/tenant/tenant_ticket_list_page.dart';
import '../../features/maintenance_ticket/presentation/pages/tenant/tenant_ticket_detail_page.dart';
import '../../features/maintenance_ticket/presentation/pages/tenant/tenant_complaint_history_page.dart';
import '../../features/iam/presentation/pages/role_list_page.dart';
import '../../features/iam/presentation/pages/role_create_page.dart';
import '../../features/iam/presentation/pages/role_detail_page.dart';
import '../../features/iam/presentation/pages/permission_list_page.dart';
import '../../features/iam/presentation/pages/permission_create_page.dart';
import '../../features/iam/presentation/pages/permission_detail_page.dart';
import '../../features/iam/presentation/pages/user_list_page.dart';
import '../../features/iam/presentation/pages/user_create_page.dart';
import '../../features/iam/presentation/pages/user_detail_page.dart';
import '../../features/notification/presentation/pages/notification_list_page.dart';
import '../../features/notification/presentation/bloc/notification_bloc.dart';
import '../../features/notification/presentation/bloc/notification_event.dart';
import '../../features/notification/data/repositories/notification_repository.dart';
import '../../features/department/presentation/pages/department_list_page.dart';
import '../../features/department/presentation/pages/department_create_page.dart';
import '../../features/department/presentation/pages/department_detail_page.dart';
import '../../features/villa/presentation/pages/villa_list_page.dart';
import '../../features/villa/presentation/pages/villa_create_page.dart';
import '../../features/villa/presentation/pages/villa_detail_page.dart';
import '../../features/villa/presentation/pages/villa_type_config_list_page.dart';
import '../../features/villa/presentation/pages/villa_type_config_create_page.dart';
import '../../features/maintenance_ticket/presentation/pages/admin/ticket_category_list_page.dart';
import '../../features/maintenance_ticket/presentation/pages/admin/ticket_category_create_page.dart';
import '../../features/maintenance_ticket/presentation/pages/admin/sla_configuration_list_page.dart';
import '../../features/maintenance_ticket/presentation/pages/admin/sla_configuration_create_page.dart';
import '../../features/company/presentation/pages/company_list_page.dart';
import '../../features/company/presentation/pages/company_create_page.dart';
import '../../features/company/presentation/pages/company_detail_page.dart';
import '../../features/site/presentation/pages/site_list_page.dart';
import '../../features/site/presentation/pages/site_create_page.dart';
import '../../features/site/presentation/pages/site_detail_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/personal_information_page.dart';
import '../../features/profile/presentation/pages/security_password_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/notification/presentation/pages/email_templates_list_page.dart';
import '../../features/notification/presentation/pages/email_template_edit_page.dart';
import '../../features/announcement/presentation/pages/announcement_list_page.dart';
import '../../features/announcement/presentation/pages/announcement_create_page.dart';
import '../di/service_locator.dart';
import '../utils/permission_checker.dart';
import '../utils/role_access_control.dart';
import '../notifications/push_notification_service.dart';
import 'page_transitions.dart';

class AppRouter {
  AppRouter(this.authBloc) {
    // Track if this is the first redirect (initial load)
    _isInitialLoad = true;
    // Reset after first redirect completes
    Future.delayed(const Duration(milliseconds: 100), () {
      _isInitialLoad = false;
    });
  }

  final AuthBloc authBloc;
  bool _isInitialLoad = true;

  GoRouter get router => _router;

  late final GoRouter _router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: _AuthNotifier(authBloc),
    redirect: _handleRedirect,
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => PageTransitions.fade(
          context,
          state,
          const SplashPage(),
        ),
      ),
      GoRoute(
        path: '/company-selection',
        pageBuilder: (context, state) => PageTransitions.slideAuto(
          context,
          state,
          const CompanySelectionPage(),
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) {
          final companyId = state.uri.queryParameters['companyId'];
          final companyName = state.uri.queryParameters['companyName'];
          final siteCode = state.uri.queryParameters['siteCode'];
          final siteId = state.uri.queryParameters['siteId'];
          return PageTransitions.slideAuto(
            context,
            state,
            LoginPage(
              companyId: companyId,
              companyName: companyName,
              siteCode: siteCode,
              siteId: siteId,
            ),
          );
        },
      ),
      GoRoute(
        path: '/forgot-password',
        pageBuilder: (context, state) {
          final companyId = state.uri.queryParameters['companyId'];
          final companyName = state.uri.queryParameters['companyName'];
          return PageTransitions.slideAuto(
            context,
            state,
            ForgotPasswordPage(
              companyId: companyId,
              companyName: companyName,
            ),
          );
        },
      ),
      GoRoute(
        path: '/forgot-password/verify-otp',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final email = extra?['email'] as String? ?? '';
          final companyId = extra?['companyId'] as String? ?? '';
          return PageTransitions.slideAuto(
            context,
            state,
            VerifyOtpPage(
              email: email,
              companyId: companyId,
            ),
          );
        },
      ),
      GoRoute(
        path: '/forgot-password/reset',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final email = extra?['email'] as String? ?? '';
          final token = extra?['token'] as String? ?? '';
          final companyId = extra?['companyId'] as String? ?? '';
          return PageTransitions.slideAuto(
            context,
            state,
            ResetPasswordPage(
              email: email,
              token: token,
              companyId: companyId,
            ),
          );
        },
      ),
      GoRoute(
        path: '/dashboard',
        redirect: (context, state) {
          final authState = authBloc.state;
          final isLoggedIn = authState.maybeWhen(
                authenticated: (_) => true,
                orElse: () => false,
              ) ??
              false;
          // Redirect to login if not authenticated
          if (!isLoggedIn) {
            return '/login';
          }
          return null;
        },
        pageBuilder: (context, state) {
          final authState = authBloc.state;
          String? userRole;
          authState.maybeWhen(
            authenticated: (user) {
              print('🔍 Dashboard Route - User roles: ${user.roles}');
              print(
                  '🔍 Dashboard Route - User roles count: ${user.roles.length}');
              if (user.roles.isNotEmpty) {
                // Check for SUPER_ADMIN first (highest priority)
                // Try multiple variations to handle different formats
                final hasSuperAdmin = user.roles.any((role) {
                  final upperRole = role.toUpperCase().trim();
                  final matches = upperRole == 'SUPER_ADMIN' ||
                      upperRole == 'SUPERADMIN' ||
                      upperRole.contains('SUPER_ADMIN');
                  if (matches) {
                    print(
                        '✅ Found SUPER_ADMIN role: $role (normalized: $upperRole)');
                  }
                  return matches;
                });

                if (hasSuperAdmin) {
                  userRole = 'SUPER_ADMIN';
                  print('✅ Setting userRole to SUPER_ADMIN');
                } else {
                  // Otherwise use first role
                  userRole = user.roles.first;
                  print(
                      '⚠️ SUPER_ADMIN not found, using first role: $userRole');
                }
              } else {
                print('⚠️ User has no roles!');
              }
            },
            orElse: () {
              print('⚠️ User not authenticated in dashboard route');
            },
          );
          print('🏠 Building dashboard for role: $userRole');
          print('🏠 Final userRole value: $userRole');
          return PageTransitions.slideAuto(
            context,
            state,
            MultiBlocProvider(
              providers: [
                BlocProvider<DashboardBloc>(
                  create: (context) => DashboardBloc(
                    dashboardRepository: getIt(),
                  ),
                ),
                // Provide NotificationBloc at route level so it's shared with notification page
                BlocProvider<NotificationBloc>(
                  create: (context) => NotificationBloc(
                    repository: getIt<NotificationRepository>(),
                  )..add(const LoadNotificationList()),
                ),
              ],
              child: _buildDashboardForRole(userRole),
            ),
          );
        },
      ),
      // IAM Routes
      GoRoute(
        path: '/iam/roles',
        redirect: (context, state) => _checkPermissionAndRedirect(
          context,
          state,
          'role',
          'read',
        ),
        pageBuilder: (context, state) => PageTransitions.slideAuto(
          context,
          state,
          const RoleListPage(),
        ),
      ),
      GoRoute(
        path: '/iam/roles/create',
        redirect: (context, state) => _checkPermissionAndRedirect(
          context,
          state,
          'role',
          'create',
        ),
        pageBuilder: (context, state) => PageTransitions.slideAuto(
          context,
          state,
          const RoleCreatePage(),
        ),
      ),
      GoRoute(
        path: '/iam/roles/:id',
        redirect: (context, state) => _checkPermissionAndRedirect(
          context,
          state,
          'role',
          'read',
        ),
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return PageTransitions.slideAuto(
            context,
            state,
            RoleDetailPage(roleId: id),
          );
        },
      ),
      GoRoute(
        path: '/iam/permissions',
        redirect: (context, state) => _checkPermissionAndRedirect(
          context,
          state,
          'permission',
          'read',
        ),
        pageBuilder: (context, state) => PageTransitions.slideAuto(
          context,
          state,
          const PermissionListPage(),
        ),
      ),
      GoRoute(
        path: '/iam/permissions/create',
        redirect: (context, state) => _checkPermissionAndRedirect(
          context,
          state,
          'permission',
          'create',
        ),
        pageBuilder: (context, state) => PageTransitions.slideAuto(
          context,
          state,
          const PermissionCreatePage(),
        ),
      ),
      GoRoute(
        path: '/iam/permissions/:id',
        redirect: (context, state) => _checkPermissionAndRedirect(
          context,
          state,
          'permission',
          'read',
        ),
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return PageTransitions.slideAuto(
            context,
            state,
            PermissionDetailPage(permissionId: id),
          );
        },
      ),
      // User Routes
      GoRoute(
        path: '/iam/users',
        redirect: (context, state) => _checkPermissionAndRedirect(
          context,
          state,
          'user',
          'read',
        ),
        pageBuilder: (context, state) {
          // Support both query parameter and extra data for companyId
          final companyId = state.uri.queryParameters['companyId'] ??
              (state.extra is Map<String, dynamic>
                  ? (state.extra as Map<String, dynamic>)['companyId']
                      as String?
                  : null);
          return PageTransitions.slideAuto(
            context,
            state,
            UserListPage(initialCompanyId: companyId),
          );
        },
      ),
      GoRoute(
        path: '/iam/users/create',
        redirect: (context, state) => _checkPermissionAndRedirect(
          context,
          state,
          'user',
          'create',
        ),
        pageBuilder: (context, state) => PageTransitions.slideAuto(
          context,
          state,
          const UserCreatePage(),
        ),
      ),
      GoRoute(
        path: '/iam/users/:id',
        redirect: (context, state) => _checkPermissionAndRedirect(
          context,
          state,
          'user',
          'read',
        ),
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          // Extract companyId from extra data if available
          final companyId = state.extra is Map<String, dynamic>
              ? (state.extra as Map<String, dynamic>)['companyId'] as String?
              : null;
          return PageTransitions.slideAuto(
            context,
            state,
            UserDetailPage(userId: id, companyId: companyId),
          );
        },
      ),
      // Notification Routes
      GoRoute(
        path: '/notifications',
        pageBuilder: (context, state) => PageTransitions.slideAuto(
          context,
          state,
          const NotificationListPage(),
        ),
      ),
      // Announcement Routes
      GoRoute(
        path: '/announcements',
        redirect: (context, state) => _checkPermissionAndRedirect(
          context,
          state,
          'announcement',
          'read',
        ),
        pageBuilder: (context, state) => PageTransitions.slideAuto(
          context,
          state,
          const AnnouncementListPage(),
        ),
      ),
      GoRoute(
        path: '/announcements/create',
        redirect: (context, state) => _checkPermissionAndRedirect(
          context,
          state,
          'announcement',
          'create',
        ),
        pageBuilder: (context, state) => PageTransitions.slideAuto(
          context,
          state,
          const AnnouncementCreatePage(),
        ),
      ),
      // Maintenance Tickets
      GoRoute(
        path: '/maintenance-tickets',
        pageBuilder: (context, state) {
          final status = state.uri.queryParameters['status']?.toUpperCase();
          final priority = state.uri.queryParameters['priority']?.toUpperCase();
          final villaNumber = state.uri.queryParameters['villaNumber'];
          return PageTransitions.slideAuto(
            context,
            state,
            MaintenanceTicketListPage(
              statusFilter: status,
              priorityFilter: priority,
              villaNumbersFilter: villaNumber != null && villaNumber.isNotEmpty
                  ? [villaNumber]
                  : null,
            ),
          );
        },
      ),
      GoRoute(
        path: '/maintenance-tickets/create',
        pageBuilder: (context, state) => PageTransitions.slideAuto(
          context,
          state,
          const AdminTicketCreateAiPage(),
        ),
      ),
      GoRoute(
        path: '/maintenance-tickets/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          // Check if user is a technician and route to technician-specific page
          final authState = authBloc.state;
          final isTechnician = authState.maybeWhen(
                authenticated: (user) => RoleAccessControl.isTechnician(user),
                orElse: () => false,
              ) ??
              false;

          final page = isTechnician
              ? TechnicianTicketDetailPage(ticketId: id)
              : MaintenanceTicketDetailPageEnhanced(ticketId: id);

          return PageTransitions.slideAuto(context, state, page);
        },
      ),
      // Tenant-specific routes
      GoRoute(
        path: '/tenant/complaints',
        pageBuilder: (context, state) {
          final status = state.uri.queryParameters['status'];
          return PageTransitions.slideAuto(
            context,
            state,
            TenantTicketListPage(statusFilter: status),
          );
        },
      ),

      GoRoute(
        path: '/tenant/complaints/create/ai',
        pageBuilder: (context, state) => PageTransitions.slideAuto(
          context,
          state,
          const TenantComplaintCreateAiPage(),
        ),
      ),
      GoRoute(
        path: '/tenant/complaints/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return PageTransitions.slideAuto(
            context,
            state,
            TenantTicketDetailPage(ticketId: id),
          );
        },
      ),
      GoRoute(
        path: '/tenant/complaints/history',
        pageBuilder: (context, state) => PageTransitions.slideAuto(
          context,
          state,
          const TenantComplaintHistoryPage(),
        ),
      ),
      // Departments
      GoRoute(
        path: '/departments',
        pageBuilder: (context, state) => PageTransitions.slideAuto(
          context,
          state,
          const DepartmentListPage(),
        ),
      ),
      GoRoute(
        path: '/departments/create',
        pageBuilder: (context, state) => PageTransitions.slideAuto(
          context,
          state,
          const DepartmentCreatePage(),
        ),
      ),
      GoRoute(
        path: '/departments/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return PageTransitions.slideAuto(
            context,
            state,
            DepartmentDetailPage(departmentId: id),
          );
        },
      ),
      // Villas
      GoRoute(
        path: '/villas',
        redirect: (context, state) => _checkPermissionAndRedirect(
          context,
          state,
          'villas',
          'read',
        ),
        pageBuilder: (context, state) => PageTransitions.slideAuto(
          context,
          state,
          const VillaListPage(),
        ),
      ),
      GoRoute(
        path: '/villas/create',
        redirect: (context, state) => _checkPermissionAndRedirect(
          context,
          state,
          'villas',
          'create',
        ),
        pageBuilder: (context, state) => PageTransitions.slideAuto(
          context,
          state,
          const VillaCreatePage(),
        ),
      ),
      GoRoute(
        path: '/villas/:id',
        redirect: (context, state) => _checkPermissionAndRedirect(
          context,
          state,
          'villas',
          'read',
        ),
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return PageTransitions.slideAuto(
            context,
            state,
            VillaDetailPage(villaId: id),
          );
        },
      ),
      // Villa Types
      GoRoute(
        path: '/villa-types',
        pageBuilder: (context, state) => PageTransitions.slideAuto(
          context,
          state,
          const VillaTypeConfigListPage(),
        ),
      ),
      GoRoute(
        path: '/villa-types/create',
        pageBuilder: (context, state) => PageTransitions.slideAuto(
          context,
          state,
          const VillaTypeConfigCreatePage(),
        ),
      ),
      GoRoute(
        path: '/villa-types/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return PageTransitions.slideAuto(
            context,
            state,
            const VillaTypeConfigCreatePage(),
          );
        },
      ),
      // Ticket Categories
      GoRoute(
        path: '/ticket-categories',
        pageBuilder: (context, state) => PageTransitions.slideAuto(
          context,
          state,
          const TicketCategoryListPage(),
        ),
      ),
      GoRoute(
        path: '/ticket-categories/create',
        pageBuilder: (context, state) => PageTransitions.slideAuto(
          context,
          state,
          const TicketCategoryCreatePage(),
        ),
      ),
      GoRoute(
        path: '/ticket-categories/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return PageTransitions.slideAuto(
            context,
            state,
            const TicketCategoryCreatePage(),
          );
        },
      ),
      // SLA Configuration Routes
      GoRoute(
        path: '/sla-configurations',
        redirect: (context, state) => _checkPermissionAndRedirect(
          context,
          state,
          'maintenance-ticket',
          'read',
        ),
        pageBuilder: (context, state) => PageTransitions.slideAuto(
          context,
          state,
          const SlaConfigurationListPage(),
        ),
      ),
      GoRoute(
        path: '/sla-configurations/create',
        redirect: (context, state) => _checkPermissionAndRedirect(
          context,
          state,
          'maintenance-ticket',
          'create',
        ),
        pageBuilder: (context, state) => PageTransitions.slideAuto(
          context,
          state,
          const SlaConfigurationCreatePage(),
        ),
      ),
      GoRoute(
        path: '/sla-configurations/:id',
        redirect: (context, state) => _checkPermissionAndRedirect(
          context,
          state,
          'maintenance-ticket',
          'update',
        ),
        pageBuilder: (context, state) {
          // For edit, we'll load the configuration in the page itself
          return PageTransitions.slideAuto(
            context,
            state,
            const SlaConfigurationCreatePage(),
          );
        },
      ),
      // Companies (Super Admin only)
      GoRoute(
        path: '/companies',
        redirect: (context, state) => _checkPermissionAndRedirect(
          context,
          state,
          'company',
          'read',
        ),
        pageBuilder: (context, state) => PageTransitions.slideAuto(
          context,
          state,
          const CompanyListPage(),
        ),
      ),
      GoRoute(
        path: '/companies/create',
        redirect: (context, state) => _checkPermissionAndRedirect(
          context,
          state,
          'company',
          'create',
        ),
        pageBuilder: (context, state) => PageTransitions.slideAuto(
          context,
          state,
          const CompanyCreatePage(),
        ),
      ),
      GoRoute(
        path: '/companies/:id',
        redirect: (context, state) => _checkPermissionAndRedirect(
          context,
          state,
          'company',
          'read',
        ),
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return PageTransitions.slideAuto(
            context,
            state,
            CompanyDetailPage(companyId: id),
          );
        },
      ),
      GoRoute(
        path: '/companies/:id/edit',
        redirect: (context, state) => _checkPermissionAndRedirect(
          context,
          state,
          'company',
          'update',
        ),
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return PageTransitions.slideAuto(
            context,
            state,
            CompanyCreatePage(companyId: id),
          );
        },
      ),
      GoRoute(
        path: '/companies/:id/sites',
        redirect: (context, state) => _checkPermissionAndRedirect(
          context,
          state,
          'company',
          'update',
        ),
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return PageTransitions.slideAuto(
            context,
            state,
            SiteListPage(companyId: id),
          );
        },
      ),
      GoRoute(
        path: '/companies/:id/sites/create',
        redirect: (context, state) => _checkPermissionAndRedirect(
          context,
          state,
          'company',
          'update',
        ),
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return PageTransitions.slideAuto(
            context,
            state,
            SiteCreatePage(companyId: id),
          );
        },
      ),
      GoRoute(
        path: '/sites',
        redirect: (context, state) => _checkPermissionAndRedirect(
          context,
          state,
          'company',
          'read',
        ),
        pageBuilder: (context, state) => PageTransitions.slideAuto(
          context,
          state,
          const SiteListPage(),
        ),
      ),
      GoRoute(
        path: '/sites/:id',
        redirect: (context, state) => _checkPermissionAndRedirect(
          context,
          state,
          'company',
          'read',
        ),
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return PageTransitions.slideAuto(
            context,
            state,
            SiteDetailPage(siteId: id),
          );
        },
      ),
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) => PageTransitions.slideAuto(
          context,
          state,
          const ProfilePage(),
        ),
      ),
      GoRoute(
        path: '/profile/personal-info',
        pageBuilder: (context, state) => PageTransitions.slideAuto(
          context,
          state,
          const PersonalInformationPage(),
        ),
      ),
      GoRoute(
        path: '/profile/security',
        pageBuilder: (context, state) => PageTransitions.slideAuto(
          context,
          state,
          const SecurityPasswordPage(),
        ),
      ),
      // Settings
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) => PageTransitions.slideAuto(
          context,
          state,
          const SettingsPage(),
        ),
      ),
      // Email Templates (Admin only)
      GoRoute(
        path: '/settings/email-templates',
        redirect: (context, state) => _checkPermissionAndRedirect(
          context,
          state,
          'notification',
          'read',
        ),
        pageBuilder: (context, state) => PageTransitions.slideAuto(
          context,
          state,
          const EmailTemplatesListPage(),
        ),
      ),
      GoRoute(
        path: '/settings/email-templates/:id',
        redirect: (context, state) => _checkPermissionAndRedirect(
          context,
          state,
          'notification',
          'update',
        ),
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return PageTransitions.slideAuto(
            context,
            state,
            EmailTemplateEditPage(templateId: id),
          );
        },
      ),
    ],
  );

  String? _handleRedirect(BuildContext context, GoRouterState state) {
    final authState = authBloc.state;
    
    // Check if auth check is still in progress (initial or loading state)
    final isAuthCheckInProgress = authState.maybeWhen(
      initial: () => true,
      loading: () => true,
      orElse: () => false,
    ) ?? false;
    
    // On initial load or if auth check is in progress, always go to splash first
    // This ensures we wait for auth check to complete before making navigation decisions
    if (_isInitialLoad || isAuthCheckInProgress) {
      final isSplash = state.matchedLocation == '/splash';
      if (isSplash) {
        print('⏳ Initial load/auth check in progress, staying on splash');
        return null; // Let splash handle it
      }
      // If not on splash and auth check in progress, go to splash first
      print('⏳ Initial load/auth check in progress, redirecting to splash from ${state.matchedLocation}');
      return '/splash';
    }
    
    final isLoggedIn = authState.maybeWhen(
          authenticated: (_) => true,
          orElse: () => false,
        ) ??
        false;
    
    print('🔍 Redirect handler - isLoggedIn: $isLoggedIn, state: ${authState.runtimeType}, location: ${state.matchedLocation}');
    final isLoggingIn = state.matchedLocation == '/login';
    final isSplash = state.matchedLocation == '/splash';
    final isCompanySelection = state.matchedLocation == '/company-selection';
    final isForgotPassword =
        state.matchedLocation.startsWith('/forgot-password');

    // Allow splash screen to handle its own navigation
    if (isSplash) {
      return null;
    }

    // Allow company selection page for unauthenticated users
    if (isCompanySelection) {
      return null;
    }

    // Allow forgot password flow for unauthenticated users
    if (isForgotPassword) {
      return null;
    }

    // Protect routes that require authentication
    if (!isLoggedIn &&
        !isLoggingIn &&
        !isSplash &&
        !isCompanySelection &&
        !isForgotPassword) {
      // Check if we have companyId stored - if yes, go to login with it
      // Otherwise, let login page redirect to company-selection
      // Note: We can't use async here, so we'll let the login page handle companyId check
      print('🔒 Redirecting to login - user not authenticated (state: ${authState.runtimeType})');
      // The login page will check for companyId in storage and redirect to company-selection if needed
      return '/login';
    }

    // Redirect authenticated users away from login/company-selection to dashboard
    if (isLoggedIn && (isLoggingIn || isCompanySelection)) {
      print('✅ User authenticated, redirecting to dashboard');
      return '/dashboard';
    }

    return null;
  }

  Widget _buildDashboardForRole(String? role) {
    final normalizedRole = role?.toUpperCase().trim() ?? '';
    print(
        '🔍 _buildDashboardForRole called with role: "$role" (normalized: "$normalizedRole")');

    // Handle SUPER_ADMIN with multiple checks
    if (normalizedRole == 'SUPER_ADMIN' ||
        normalizedRole == 'SUPERADMIN' ||
        normalizedRole.contains('SUPER_ADMIN')) {
      print('✅ Returning SuperAdminDashboardPage');
      return const SuperAdminDashboardPage();
    }

    switch (normalizedRole) {
      case 'ADMIN':
        print('✅ Returning AdminDashboardPage');
        return const AdminDashboardPage();
      case 'SITE_COORDINATOR':
        print('✅ Returning SiteCoordinatorDashboardPage');
        return const SiteCoordinatorDashboardPage();
      case 'SUPERVISOR':
        print('✅ Returning SupervisorDashboardPage');
        return const SupervisorDashboardPage();
      case 'TENANT':
        print('✅ Returning TenantDashboardPage');
        return const TenantDashboardPage();
      case 'TECHNICIAN':
        print('✅ Returning TechnicianDashboardPage');
        return const TechnicianDashboardPage();
      default:
        print(
            '⚠️ Unknown role "$normalizedRole", defaulting to TenantDashboardPage');
        return const TenantDashboardPage();
    }
  }

  /// Check permission and redirect if user doesn't have access
  String? _checkPermissionAndRedirect(
    BuildContext context,
    GoRouterState state,
    String resource,
    String action,
  ) {
    final authState = authBloc.state;
    final hasPermission = authState.maybeWhen(
          authenticated: (user) {
            return PermissionChecker.canPerform(user, resource, action);
          },
          orElse: () => false,
        ) ??
        false;

    if (!hasPermission) {
      return '/dashboard';
    }
    return null;
  }
}

class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier(this.authBloc) {
    _subscription = authBloc.stream.listen((state) {
      // Register FCM token when user becomes authenticated
      state.when(
        initial: () {},
        loading: () {},
        authenticated: (_) {
          // Register FCM token after successful authentication
          PushNotificationService()
              .registerTokenAfterAuth()
              .catchError((Object e) {
            // Log but don't block - token registration failure shouldn't prevent login
            debugPrint('⚠️ Failed to register FCM token after auth: $e');
          });
        },
        unauthenticated: () {
          // Mark as unauthenticated when user logs out
          PushNotificationService().markAsUnauthenticated();
        },
        error: (_) {},
      );
      notifyListeners();
    });
  }

  final AuthBloc authBloc;
  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
