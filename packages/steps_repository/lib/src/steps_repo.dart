import 'package:steps_repository/steps_repository.dart';

abstract class StepsRepository{

  Future<void> setStepsData(Steps steps);
}