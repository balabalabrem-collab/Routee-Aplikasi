class TransportModel {
  final String id;
  final String icon;
  final String name;
  final String image;
  final String price;
  final String desc;
  final List<String> pros;
  final List<String> cons;
  final String colorHex;
  final String badge;

  const TransportModel({
    required this.id,
    required this.icon,
    required this.name,
    required this.image,
    required this.price,
    required this.desc,
    required this.pros,
    required this.cons,
    required this.colorHex,
    required this.badge,
  });
}
