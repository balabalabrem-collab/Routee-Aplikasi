class CulinaryModel {
  final String id;
  final String name;
  final String image;
  final String distance;
  final double rating;
  final String duration;
  final String price;
  final String desc;
  final String area;
  final String group;
  final String imageSource;

  const CulinaryModel({
    required this.id,
    required this.name,
    required this.image,
    required this.distance,
    required this.rating,
    required this.duration,
    required this.price,
    required this.desc,
    required this.area,
    required this.group,
    this.imageSource = 'Google Images',
  });
}
