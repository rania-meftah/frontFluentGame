class DomaineModel {
  final String id;
  final String name;
  final String image;

  DomaineModel({required this.id, required this.name, required this.image});

  factory DomaineModel.fromJson(Map<String, dynamic> json) {
    return DomaineModel(
      id: json['_id'],
      name: json['name'],
      image: json['image'] ?? "", // facultatif
    );
  }
}
