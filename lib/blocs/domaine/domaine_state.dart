import 'package:my_flutter_app/models/DomaineModel.dart';

abstract class DomaineState {}

class DomaineInitial extends DomaineState {}

class DomaineLoading extends DomaineState {}

class DomaineLoaded extends DomaineState {
  final List<DomaineModel> domaines;

  DomaineLoaded(this.domaines);
}

class DomaineError extends DomaineState {
  final String message;

  DomaineError(this.message);
}
