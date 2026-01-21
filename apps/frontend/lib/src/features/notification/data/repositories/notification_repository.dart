import 'package:fpdart/fpdart.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/entities/notification_entity.dart';
import '../dto/notification_template_dto.dart';
import '../mappers/notification_mapper.dart';

class NotificationRepository {
  NotificationRepository({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<Either<Exception, List<NotificationEntity>>> getNotifications() async {
    try {
      final dtos = await _apiClient.getNotifications();
      final entities = dtos.map(NotificationMapper.dtoToEntity).toList();
      return Right(entities);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  Future<Either<Exception, NotificationEntity>> markAsRead(String id) async {
    try {
      final dto = await _apiClient.markNotificationAsRead(id);
      return Right(NotificationMapper.dtoToEntity(dto));
    } on Exception catch (e) {
      return Left(e);
    }
  }

  Future<Either<Exception, void>> markAllAsRead() async {
    try {
      await _apiClient.markAllNotificationsAsRead();
      return const Right(null);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  // Template Management
  Future<Either<Exception, List<NotificationTemplateDto>>> getEmailTemplates() async {
    try {
      final dtos = await _apiClient.getEmailTemplates();
      return Right(dtos);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  Future<Either<Exception, NotificationTemplateDto>> getTemplate(String id) async {
    try {
      final dto = await _apiClient.getNotificationTemplate(id);
      return Right(dto);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  Future<Either<Exception, NotificationTemplateDto>> updateTemplate(
    String id,
    NotificationTemplateDto template,
  ) async {
    try {
      final dto = await _apiClient.updateNotificationTemplate(id, template.toUpdateJson());
      return Right(dto);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  Future<Either<Exception, void>> seedEmailTemplates() async {
    try {
      await _apiClient.seedEmailTemplates();
      return const Right(null);
    } on Exception catch (e) {
      return Left(e);
    }
  }
}
