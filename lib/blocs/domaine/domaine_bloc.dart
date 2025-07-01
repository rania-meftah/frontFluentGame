import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flutter_app/models/DomaineModel.dart';
import 'package:my_flutter_app/repositories/DomaineRepository.dart';

abstract class DomaineEvent {}

class LoadDomaines extends DomaineEvent {}

abstract class DomaineState {}

class DomaineLoading extends DomaineState {}

class DomaineLoaded extends DomaineState {
  final List<DomaineModel> domaines;
  DomaineLoaded(this.domaines);
}

class DomaineError extends DomaineState {
  final String message;
  DomaineError(this.message);
}

class DomaineBloc extends Bloc<DomaineEvent, DomaineState> {
  final DomaineRepository repository;

  DomaineBloc(this.repository) : super(DomaineLoading()) {
    on<LoadDomaines>((event, emit) async {
      try {
        emit(DomaineLoading());
        final domaines = await repository.fetchDomaines();
        emit(DomaineLoaded(domaines));
      } catch (e) {
        emit(DomaineError(e.toString()));
      }
    });
  }
}
