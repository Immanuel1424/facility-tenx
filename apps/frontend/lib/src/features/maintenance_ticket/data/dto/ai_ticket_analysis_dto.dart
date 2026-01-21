class AiTicketAnalysisDto {
  const AiTicketAnalysisDto({
    required this.title,
    required this.category,
    required this.priority,
    this.description,
    this.location,
    this.contactNumber,
    this.preferredTime,
  });

  final String title;
  final String category;
  final String priority;
  final String? description;
  final String? location;
  final String? contactNumber;
  final String? preferredTime;

  factory AiTicketAnalysisDto.fromJson(Map<String, dynamic> json) {
    return AiTicketAnalysisDto(
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? 'MISCELLANEOUS',
      priority: json['priority'] as String? ?? 'MEDIUM',
      description: json['description'] as String?,
      location: json['location'] as String?,
      contactNumber: json['contact_number'] as String? ?? json['contactNumber'] as String?,
      preferredTime: json['preferred_time'] as String? ?? json['preferredTime'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'category': category,
      'priority': priority,
      if (description != null) 'description': description,
      if (location != null) 'location': location,
      if (contactNumber != null) 'contact_number': contactNumber,
      if (preferredTime != null) 'preferred_time': preferredTime,
    };
  }
}

