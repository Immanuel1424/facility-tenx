import '../../domain/entities/maintenance_ticket_entity.dart';

class SlaConfigurationDto {
  const SlaConfigurationDto({
    required this.id,
    required this.company_id,
    required this.name,
    this.description,
    required this.priority,
    required this.first_response_time_minutes,
    required this.acknowledgement_time_minutes,
    required this.resolution_time_minutes,
    this.escalation_level_1_minutes,
    this.escalation_level_2_minutes,
    this.escalation_level_3_minutes,
    this.apply_business_hours = true,
    this.business_start_time,
    this.business_end_time,
    this.working_days,
    this.exclude_holidays = true,
    this.is_active = true,
    this.created_by_id,
    required this.created_at,
    required this.updated_at,
  });

  final String id;
  final String company_id;
  final String name;
  final String? description;
  final String priority;
  final int first_response_time_minutes;
  final int acknowledgement_time_minutes;
  final int resolution_time_minutes;
  final int? escalation_level_1_minutes;
  final int? escalation_level_2_minutes;
  final int? escalation_level_3_minutes;
  final bool apply_business_hours;
  final String? business_start_time;
  final String? business_end_time;
  final String? working_days;
  final bool exclude_holidays;
  final bool is_active;
  final String? created_by_id;
  final DateTime created_at;
  final DateTime updated_at;

  factory SlaConfigurationDto.fromJson(Map<String, dynamic> json) {
    return SlaConfigurationDto(
      id: json['id'] as String,
      company_id: json['company_id'] as String? ?? json['companyId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      priority: json['priority'] as String,
      first_response_time_minutes:
          json['first_response_time_minutes'] as int? ??
              json['firstResponseTimeMinutes'] as int,
      acknowledgement_time_minutes:
          json['acknowledgement_time_minutes'] as int? ??
              json['acknowledgementTimeMinutes'] as int,
      resolution_time_minutes: json['resolution_time_minutes'] as int? ??
          json['resolutionTimeMinutes'] as int,
      escalation_level_1_minutes:
          json['escalation_level_1_minutes'] as int? ??
              json['escalationLevel1Minutes'] as int?,
      escalation_level_2_minutes:
          json['escalation_level_2_minutes'] as int? ??
              json['escalationLevel2Minutes'] as int?,
      escalation_level_3_minutes:
          json['escalation_level_3_minutes'] as int? ??
              json['escalationLevel3Minutes'] as int?,
      apply_business_hours: json['apply_business_hours'] as bool? ??
          json['applyBusinessHours'] as bool? ??
          true,
      business_start_time: json['business_start_time'] as String? ??
          json['businessStartTime'] as String?,
      business_end_time:
          json['business_end_time'] as String? ??
              json['businessEndTime'] as String?,
      working_days:
          json['working_days'] as String? ?? json['workingDays'] as String?,
      exclude_holidays: json['exclude_holidays'] as bool? ??
          json['excludeHolidays'] as bool? ??
          true,
      is_active:
          json['is_active'] as bool? ?? json['isActive'] as bool? ?? true,
      created_by_id:
          json['created_by_id'] as String? ?? json['createdById'] as String?,
      created_at: DateTime.parse(json['created_at'] as String? ??
          json['createdAt'] as String),
      updated_at: DateTime.parse(
          json['updated_at'] as String? ?? json['updatedAt'] as String),
    );
  }
}

class CreateSlaConfigurationDto {
  const CreateSlaConfigurationDto({
    required this.name,
    this.description,
    required this.priority,
    required this.first_response_time_minutes,
    required this.acknowledgement_time_minutes,
    required this.resolution_time_minutes,
    this.escalation_level_1_minutes,
    this.escalation_level_2_minutes,
    this.escalation_level_3_minutes,
    this.apply_business_hours = true,
    this.business_start_time,
    this.business_end_time,
    this.working_days,
    this.exclude_holidays = true,
  });

  final String name;
  final String? description;
  final String priority;
  final int first_response_time_minutes;
  final int acknowledgement_time_minutes;
  final int resolution_time_minutes;
  final int? escalation_level_1_minutes;
  final int? escalation_level_2_minutes;
  final int? escalation_level_3_minutes;
  final bool apply_business_hours;
  final String? business_start_time;
  final String? business_end_time;
  final String? working_days;
  final bool exclude_holidays;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null) 'description': description,
      'priority': priority,
      'first_response_time_minutes': first_response_time_minutes,
      'acknowledgement_time_minutes': acknowledgement_time_minutes,
      'resolution_time_minutes': resolution_time_minutes,
      if (escalation_level_1_minutes != null)
        'escalation_level_1_minutes': escalation_level_1_minutes,
      if (escalation_level_2_minutes != null)
        'escalation_level_2_minutes': escalation_level_2_minutes,
      if (escalation_level_3_minutes != null)
        'escalation_level_3_minutes': escalation_level_3_minutes,
      'apply_business_hours': apply_business_hours,
      if (business_start_time != null)
        'business_start_time': business_start_time,
      if (business_end_time != null) 'business_end_time': business_end_time,
      if (working_days != null) 'working_days': working_days,
      'exclude_holidays': exclude_holidays,
    };
  }
}

class UpdateSlaConfigurationDto {
  const UpdateSlaConfigurationDto({
    this.name,
    this.description,
    this.priority,
    this.first_response_time_minutes,
    this.acknowledgement_time_minutes,
    this.resolution_time_minutes,
    this.escalation_level_1_minutes,
    this.escalation_level_2_minutes,
    this.escalation_level_3_minutes,
    this.apply_business_hours,
    this.business_start_time,
    this.business_end_time,
    this.working_days,
    this.exclude_holidays,
    this.is_active,
  });

  final String? name;
  final String? description;
  final String? priority;
  final int? first_response_time_minutes;
  final int? acknowledgement_time_minutes;
  final int? resolution_time_minutes;
  final int? escalation_level_1_minutes;
  final int? escalation_level_2_minutes;
  final int? escalation_level_3_minutes;
  final bool? apply_business_hours;
  final String? business_start_time;
  final String? business_end_time;
  final String? working_days;
  final bool? exclude_holidays;
  final bool? is_active;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (name != null) json['name'] = name;
    if (description != null) json['description'] = description;
    if (priority != null) json['priority'] = priority;
    if (first_response_time_minutes != null) {
      json['first_response_time_minutes'] = first_response_time_minutes;
    }
    if (acknowledgement_time_minutes != null) {
      json['acknowledgement_time_minutes'] = acknowledgement_time_minutes;
    }
    if (resolution_time_minutes != null) {
      json['resolution_time_minutes'] = resolution_time_minutes;
    }
    if (escalation_level_1_minutes != null) {
      json['escalation_level_1_minutes'] = escalation_level_1_minutes;
    }
    if (escalation_level_2_minutes != null) {
      json['escalation_level_2_minutes'] = escalation_level_2_minutes;
    }
    if (escalation_level_3_minutes != null) {
      json['escalation_level_3_minutes'] = escalation_level_3_minutes;
    }
    if (apply_business_hours != null) {
      json['apply_business_hours'] = apply_business_hours;
    }
    if (business_start_time != null) {
      json['business_start_time'] = business_start_time;
    }
    if (business_end_time != null) {
      json['business_end_time'] = business_end_time;
    }
    if (working_days != null) json['working_days'] = working_days;
    if (exclude_holidays != null) json['exclude_holidays'] = exclude_holidays;
    if (is_active != null) json['is_active'] = is_active;
    return json;
  }
}
