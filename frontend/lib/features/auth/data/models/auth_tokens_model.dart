import 'package:json_annotation/json_annotation.dart';

part 'auth_tokens_model.g.dart';

@JsonSerializable()
class AuthTokensModel {
  final String accessToken;
  final String refreshToken;
  final String? userId;

  const AuthTokensModel({
    required this.accessToken,
    required this.refreshToken,
    this.userId,
  });

  factory AuthTokensModel.fromJson(Map<String, dynamic> json) =>
      _$AuthTokensModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthTokensModelToJson(this);
}
