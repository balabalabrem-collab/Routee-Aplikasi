class DestinationModel {
  final String id;
  final String name;
  final String category;
  final String image;
  final String shortDesc;
  final String description;
  final String location;
  final String hours;
  final String ticket;
  final String duration;
  final double rating;
  final double lat;
  final double lng;
  final String imageSource;

  const DestinationModel({
    required this.id,
    required this.name,
    required this.category,
    required this.image,
    required this.shortDesc,
    required this.description,
    required this.location,
    required this.hours,
    required this.ticket,
    required this.duration,
    required this.rating,
    required this.lat,
    required this.lng,
    this.imageSource = 'Google Images',
  });
}
