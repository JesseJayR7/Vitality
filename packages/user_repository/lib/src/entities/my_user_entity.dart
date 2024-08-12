import 'package:equatable/equatable.dart';

// ignore: must_be_immutable
class MyUserEntity extends Equatable {
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

  MyUserEntity({
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

  Map<String, Object?> toDocument() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'weightValue': weightValue,
      'weightUnit': weightUnit,
      'heightValue': heightValue,
      'heightUnit': heightUnit,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  static MyUserEntity fromDocument(Map<String, dynamic> doc) {
    return MyUserEntity(
      id: doc['id'] as String,
      email: doc['email'] as String,
      name: doc['name'] as String,
      dateOfBirth: doc['dateOfBirth'] as String,
      gender: doc['gender'] as String,
      weightValue: doc['weightValue'] as double,
      weightUnit: doc['weightUnit'] as String,
      heightValue: doc['heightValue'] as double,
      heightUnit: doc['heightUnit'] as String,
      createdAt: doc['createdAt'] as String,
      updatedAt: doc['updatedAt'] as String,
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

  @override
  String toString() {
    return '''UserEntity: {
      id: $id
      email: $email
      name: $name
      dateOfBirth: $dateOfBirth,
      gender: $gender,
      weightValue: $weightValue,
      weightUnit: $weightUnit,
      heightValue: $heightValue,
      heightUnit: $heightUnit,
      createdAt: $createdAt,
      updatedAt: $updatedAt,
    }''';
  }
}
