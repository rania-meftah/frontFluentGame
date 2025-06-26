import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flutter_app/blocs/children/children_event.dart';
import 'package:my_flutter_app/blocs/children/children_state.dart';
import 'package:my_flutter_app/repositories/children_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ChildrenBloc extends Bloc<ChildrenEvent, ChildrenState> {
  final ChildrenRepository repository;

  ChildrenBloc(this.repository) : super(ChildrenInitial()) {
    // 🔄 Charger les enfants du parent
    on<LoadChildren>((event, emit) async {
      emit(ChildrenLoading());
      try {
        final children = await repository.fetchChildren(
          event.parentId,
          event.token,
        );
        emit(ChildrenLoaded(children));
      } catch (e) {
        emit(ChildrenError(e.toString()));
      }
    });

    // ➕ Ajouter un nouvel enfant
   on<AddChildEvent>((event, emit) async {
  print("🧩 AddChildEvent déclenché");
  emit(ChildrenLoading());

  try {
    // 1️⃣ Ajouter l'enfant et récupérer son token
    final childToken = await repository.addChild(
      event.parentId,
      event.child,
      event.token,
    );

    print("🔐 Token enfant reçu : $childToken");

    // 2️⃣ Stocker le token de l'enfant avec une clé UNIQUE
    final storage = FlutterSecureStorage();
    await storage.write(key: 'child_token_${event.child.id}', value: childToken);

    // 3️⃣ Recharger les enfants pour l'affichage
    final children = await repository.fetchChildren(
      event.parentId,
      event.token,
    );

    print("📥 Enfants récupérés : ${children.length}");
    emit(ChildrenLoaded(children));
  } catch (e) {
    print("❌ Erreur lors de l’ajout ou du fetch: $e");
    emit(ChildrenError(e.toString()));
  }
});

    // 🗑 Supprimer un enfant
    on<DeleteChildEvent>((event, emit) async {
      try {
        await repository.deleteChild(
          event.parentId,
          event.childId,
          event.token,
        );
        add(LoadChildren(event.parentId, event.token));
      } catch (e) {
        emit(ChildrenError(e.toString()));
      }
    });
  }
}
