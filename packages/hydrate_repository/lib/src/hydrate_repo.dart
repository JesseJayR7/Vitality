import 'package:hydrate_repository/hydrate_repository.dart';

abstract class HydrateRepository{
  Future<void> setHydrateData(Hydrate hydrate);
}