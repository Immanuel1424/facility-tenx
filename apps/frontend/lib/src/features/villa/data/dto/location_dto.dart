class LocationDto {
  const LocationDto({
    required this.id,
    required this.cityId,
    required this.name,
    this.code,
    required this.displayOrder,
  });

  final String id;
  final String cityId;
  final String name;
  final String? code;
  final int displayOrder;

  factory LocationDto.fromJson(Map<String, dynamic> json) {
    return LocationDto(
      id: json['id'] as String,
      cityId: json['cityId'] as String,
      name: json['name'] as String,
      code: json['code'] as String?,
      displayOrder: json['displayOrder'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'cityId': cityId,
        'name': name,
        if (code != null) 'code': code,
        'displayOrder': displayOrder,
      };
}

