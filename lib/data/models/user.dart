// lib/data/models/user.dart

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User extends Equatable {
  final String id;
  final String? name;
  final String email;
  final bool isEmailVerified;
  final String? role;
  final double balance;
  final int freeOperationsRemaining;
  final String? freeOperationsReset;
  final String? tier;
  final String? status;
  final int operations;
  final int limit;

  const User({
    required this.id,
    this.name,
    required this.email,
    required this.isEmailVerified,
    this.role,
    required this.balance,
    required this.freeOperationsRemaining,
    this.freeOperationsReset,
    this.tier,
    this.status,
    required this.operations,
    required this.limit,
  });

  // Create a copy with updated fields
  User copyWith({
    String? id,
    String? name,
    String? email,
    bool? isEmailVerified,
    String? role,
    double? balance,
    int? freeOperationsRemaining,
    String? freeOperationsReset,
    String? tier,
    String? status,
    int? operations,
    int? limit,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      role: role ?? this.role,
      balance: balance ?? this.balance,
      freeOperationsRemaining: freeOperationsRemaining ?? this.freeOperationsRemaining,
      freeOperationsReset: freeOperationsReset ?? this.freeOperationsReset,
      tier: tier ?? this.tier,
      status: status ?? this.status,
      operations: operations ?? this.operations,
      limit: limit ?? this.limit,
    );
  }

  // Factory to create a User from JSON
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  // Convert User to JSON
  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    isEmailVerified,
    role,
    balance,
    freeOperationsRemaining,
    freeOperationsReset,
    tier,
    status,
    operations,
    limit,
  ];
}