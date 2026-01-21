import 'package:equatable/equatable.dart';
import '../../../data/dto/notification_template_dto.dart';

abstract class TemplateEvent extends Equatable {
  const TemplateEvent();

  @override
  List<Object?> get props => [];
}

class LoadEmailTemplates extends TemplateEvent {
  const LoadEmailTemplates();
}

class LoadTemplate extends TemplateEvent {
  const LoadTemplate(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class UpdateTemplate extends TemplateEvent {
  const UpdateTemplate({
    required this.id,
    required this.template,
  });

  final String id;
  final NotificationTemplateDto template;

  @override
  List<Object?> get props => [id, template];
}

class SeedEmailTemplates extends TemplateEvent {
  const SeedEmailTemplates();
}

