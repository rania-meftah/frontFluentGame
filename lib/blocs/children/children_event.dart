import 'package:my_flutter_app/models/child_model.dart';

abstract class ChildrenEvent {}

class LoadChildren extends ChildrenEvent {
  final String parentId;
  final String token;

  LoadChildren(this.parentId, this.token);
}

class AddChildEvent extends ChildrenEvent {
  final ChildModel child;
  final String parentId;
  final String token;

  AddChildEvent(this.child, this.parentId, this.token);
}

class DeleteChildEvent extends ChildrenEvent {
  final String childId;
  final String parentId;
  final String token;

  DeleteChildEvent(this.childId, this.parentId, this.token);
}
