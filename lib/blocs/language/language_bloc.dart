import 'package:flutter_bloc/flutter_bloc.dart';
import 'language_event.dart';
import 'language_state.dart';
import '../../services/language_service.dart';

class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  final LanguageService service;

  LanguageBloc({required this.service}) : super(LanguageInitial()) {
    on<LoadLanguagesEvent>((event, emit) async {
      emit(LanguageLoading());
      try {
        final languages = await service.fetchLanguages();
        emit(LanguageLoaded(languages));
      } catch (e) {
        emit(LanguageError(e.toString()));
      }
    });

    on<SelectLanguageEvent>((event, emit) async {
      try {
        await service.selectLanguage(event.languageId);
        emit(LanguageSelected());
      } catch (e) {
        emit(LanguageError(e.toString()));
      }
    });
  }
}
