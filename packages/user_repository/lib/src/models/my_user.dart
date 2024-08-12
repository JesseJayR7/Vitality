import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:user_repository/src/entities/entities.dart';

// ignore: must_be_immutable
class MyUser extends Equatable {
  final String id;
  final String email;
  final String name;
  final String dateOfBirth;
  final String gender;
  final double weightValue;
  final String weightUnit;
  final double heightValue;
  final String heightUnit;
  final String createdAt;
  String updatedAt;

  MyUser({
    required this.id,
    required this.email,
    required this.name,
    required this.dateOfBirth,
    required this.gender,
    required this.weightValue,
    required this.weightUnit,
    required this.heightValue,
    required this.heightUnit,
    required this.createdAt,
    required this.updatedAt,
  });

  //empty user which represents an authenticated user.
  static final empty = MyUser(
    id: '',
    email: '',
    name: '',
    dateOfBirth: '',
    gender: '',
    weightValue: 0.0,
    weightUnit: '',
    heightValue: 0.0,
    heightUnit: '',
    createdAt: DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now()),
    updatedAt: DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now()),
  );

  // modify MyUser parameters
  MyUser copyith({
    String? id,
    String? email,
    String? name,
    String? dateOfBirth,
    String? gender,
    double? weightValue,
    String? weightUnit,
    double? heightValue,
    String? heightUnit,
    String? createdAt,
    String? updatedAt,
  }) {
    return MyUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      weightValue: weightValue ?? this.weightValue,
      weightUnit: weightUnit ?? this.weightUnit,
      heightValue: heightValue ?? this.heightValue,
      heightUnit: heightUnit ?? this.heightUnit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convenience getter to determine if the current user is empty
  bool get isEmpty => this == MyUser.empty;

  /// Convenience getter to determine if the current user is not empty
  bool get isNotEmpty => this != MyUser.empty;

  MyUserEntity toEntity() {
    return MyUserEntity(
      id: id,
      email: email,
      name: name,
      dateOfBirth: dateOfBirth,
      gender: gender,
      weightValue: weightValue,
      weightUnit: weightUnit,
      heightValue: heightValue,
      heightUnit: heightUnit,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static MyUser fromEntity(MyUserEntity entity) {
    return MyUser(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      dateOfBirth: entity.dateOfBirth,
      gender: entity.gender,
      weightValue: entity.weightValue,
      weightUnit: entity.weightUnit,
      heightValue: entity.heightValue,
      heightUnit: entity.heightUnit,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        dateOfBirth,
        gender,
        weightValue,
        weightUnit,
        heightValue,
        heightUnit,
        createdAt,
        updatedAt,
      ];
}
