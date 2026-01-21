class LoginDto {
  LoginDto({
    required this.siteCode,
    required this.email,
    required this.password,
    this.companyId,
  });

  final String siteCode;
  final String email;
  final String password;
  final String? companyId;

  factory LoginDto.fromJson(Map<String, dynamic> json) => LoginDto(
        siteCode: json['siteCode'] as String,
        email: json['email'] as String,
        password: json['password'] as String,
        companyId: json['companyId'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'siteCode': siteCode,
        'email': email,
        'password': password,
        'companyId': companyId,
      };
}
