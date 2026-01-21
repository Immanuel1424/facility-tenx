class CityDto {
  const CityDto({
    required this.id,
    required this.name,
    this.code,
    this.emirate,
    required this.displayOrder,
  });

  final String id;
  final String name;
  final String? code;
  final String? emirate;
  final int displayOrder;

  factory CityDto.fromJson(Map<String, dynamic> json) {
    return CityDto(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String?,
      emirate: json['emirate'] as String?,
      displayOrder: json['displayOrder'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (code != null) 'code': code,
        if (emirate != null) 'emirate': emirate,
        'displayOrder': displayOrder,
      };
}

