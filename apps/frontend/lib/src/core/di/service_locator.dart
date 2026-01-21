import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../config/app_config.dart';
import '../network/api_client.dart';
import '../network/dio_client.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/dashboard/data/repositories/dashboard_repository.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository_interface.dart';
import '../../features/iam/data/repositories/iam_repository.dart';
import '../../features/notification/data/repositories/notification_repository.dart';
import '../../features/maintenance_ticket/data/repositories/maintenance_ticket_repository.dart';
import '../../features/maintenance_ticket/domain/repositories/maintenance_ticket_repository_interface.dart';
import '../../features/maintenance_ticket/data/repositories/comment_repository.dart';
import '../../features/maintenance_ticket/domain/repositories/comment_repository_interface.dart';
import '../../features/maintenance_ticket/data/repositories/attachment_repository.dart';
import '../../features/maintenance_ticket/domain/repositories/attachment_repository_interface.dart';
import '../../features/maintenance_ticket/data/services/ai_ticket_service.dart';
import '../../features/maintenance_ticket/domain/services/ai_ticket_service_interface.dart';
import '../../features/maintenance_ticket/data/services/file_upload_service.dart';
import '../../features/maintenance_ticket/data/services/s3_upload_service.dart';
import '../../features/announcement/data/repositories/announcement_repository.dart';
import '../../features/announcement/domain/repositories/announcement_repository_interface.dart';
import '../../features/announcement/presentation/bloc/announcement_bloc.dart';
import '../../features/company/data/repositories/company_repository.dart';
import '../../features/company/domain/repositories/company_repository_interface.dart';
import '../../features/site/data/repositories/site_repository.dart';
import '../../features/site/domain/repositories/site_repository_interface.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  try {
    // Core Services - Configure FlutterSecureStorage
    // For web, FlutterSecureStorage uses localStorage by default which works
    // in embedded browser contexts (like Cursor's browser tab)
    // The default WebOptions should work fine for most cases
    final secureStorage = const FlutterSecureStorage();
    
    getIt.registerSingleton<FlutterSecureStorage>(secureStorage);

    // Register FlutterSecureStorage early so repositories can use it

    // Network - Safely get API base URL with fallback
    String apiBaseUrl;
    try {
      apiBaseUrl = AppConfig.apiBaseUrl;
    } catch (e) {
      // Fallback if AppConfig fails
      apiBaseUrl = 'http://backend:3000/api/v1';
      debugPrint('⚠️ Failed to get API base URL from AppConfig, using fallback: $apiBaseUrl');
    }

    getIt.registerSingleton<Dio>(
      createDioClient(
        getIt<FlutterSecureStorage>(),
        apiBaseUrl,
      ),
    );
  } catch (e, stackTrace) {
    debugPrint('❌ Error in service locator setup (network): $e');
    debugPrint('Stack trace: $stackTrace');
    rethrow;
  }

  try {
    getIt.registerSingleton<ApiClient>(
      ApiClient(
        getIt<Dio>(),
      ),
    );
  } catch (e, stackTrace) {
    debugPrint('❌ Error in service locator setup (ApiClient): $e');
    debugPrint('Stack trace: $stackTrace');
    rethrow;
  }

  // Repositories
  try {
    getIt.registerSingleton<AuthRepository>(
      AuthRepository(
        apiClient: getIt<ApiClient>(),
        storage: getIt<FlutterSecureStorage>(),
      ),
    );
  } catch (e, stackTrace) {
    debugPrint('❌ Error in service locator setup (AuthRepository): $e');
    debugPrint('Stack trace: $stackTrace');
    rethrow;
  }

  getIt.registerSingleton<DashboardRepositoryInterface>(
    DashboardRepository(
      apiClient: getIt<ApiClient>(),
    ),
  );

  getIt.registerSingleton<IamRepository>(
    IamRepository(
      apiClient: getIt<ApiClient>(),
    ),
  );

  getIt.registerSingleton<NotificationRepository>(
    NotificationRepository(
      apiClient: getIt<ApiClient>(),
    ),
  );

  final maintenanceTicketRepository = MaintenanceTicketRepository(
    apiClient: getIt<ApiClient>(),
  );

  // Register as both interface and concrete class for flexibility
  getIt.registerSingleton<MaintenanceTicketRepositoryInterface>(
    maintenanceTicketRepository,
  );
  getIt.registerSingleton<MaintenanceTicketRepository>(
    maintenanceTicketRepository,
  );

  // Comment Repository
  getIt.registerSingleton<CommentRepositoryInterface>(
    CommentRepository(
      apiClient: getIt<ApiClient>(),
    ),
  );

  // Attachment Repository
  getIt.registerSingleton<AttachmentRepositoryInterface>(
    AttachmentRepository(
      apiClient: getIt<ApiClient>(),
    ),
  );

  // File Upload Service (legacy - for backward compatibility)
  getIt.registerSingleton<FileUploadService>(
    FileUploadService(getIt<Dio>()),
  );

  // S3 Direct Upload Service (new - recommended)
  // Uses a clean Dio instance internally to avoid signature issues with presigned URLs
  getIt.registerSingleton<S3UploadService>(
    S3UploadService(
      apiClient: getIt<ApiClient>(),
    ),
  );

  // AI Ticket Service (calls backend endpoint)
  getIt.registerSingleton<AiTicketServiceInterface>(
    AiTicketService(
      getIt<ApiClient>(),
    ),
  );

  // Announcement Repository
  final announcementRepository = AnnouncementRepository(
    getIt<ApiClient>(),
  );
  getIt.registerSingleton<AnnouncementRepositoryInterface>(
    announcementRepository,
  );
  getIt.registerSingleton<AnnouncementRepository>(
    announcementRepository,
  );

  // Announcement BLoC
  getIt.registerFactory<AnnouncementBloc>(
    () => AnnouncementBloc(
      repository: getIt<AnnouncementRepositoryInterface>(),
    ),
  );

  // Company Repository
  getIt.registerSingleton<CompanyRepositoryInterface>(
    CompanyRepository(
      apiClient: getIt<ApiClient>(),
    ),
  );

  // Site Repository
  getIt.registerSingleton<SiteRepositoryInterface>(
    SiteRepository(
      apiClient: getIt<ApiClient>(),
    ),
  );
}
