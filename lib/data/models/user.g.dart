// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as String,
      name: json['name'] as String?,
      email: json['email'] as String,
      isEmailVerified: json['isEmailVerified'] as bool,
      role: json['role'] as String?,
      balance: (json['balance'] as num).toDouble(),
      freeOperationsRemaining: (json['freeOperationsRemaining'] as num).toInt(),
      freeOperationsReset: json['freeOperationsReset'] as String?,
      tier: json['tier'] as String?,
      status: json['status'] as String?,
      operations: (json['operations'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'isEmailVerified': instance.isEmailVerified,
      'role': instance.role,
      'balance': instance.balance,
      'freeOperationsRemaining': instance.freeOperationsRemaining,
      'freeOperationsReset': instance.freeOperationsReset,
      'tier': instance.tier,
      'status': instance.status,
      'operations': instance.operations,
      'limit': instance.limit,
    };
