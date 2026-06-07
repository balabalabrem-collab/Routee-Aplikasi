class DriverModel {
  final String id;
  final String name;
  final String photo;
  final double rating;
  final int totalTrips;
  final String vehicleType; // 'Motor' or 'Mobil'
  final String vehicleName;
  final String plateNumber;
  final String phone;
  final bool isAvailable;
  final double lat;
  final double lng;

  const DriverModel({
    required this.id,
    required this.name,
    required this.photo,
    required this.rating,
    required this.totalTrips,
    required this.vehicleType,
    required this.vehicleName,
    required this.plateNumber,
    required this.phone,
    this.isAvailable = true,
    required this.lat,
    required this.lng,
  });
}
