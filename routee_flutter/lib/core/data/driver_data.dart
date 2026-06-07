import '../models/driver_model.dart';

class DriverData {
  static final List<DriverModel> drivers = [
    // ── MOTOR DRIVERS ──
    const DriverModel(
      id: 'drv-01',
      name: 'Agus Setiawan',
      photo: 'assets/images/placeholder.jpg',
      rating: 4.9,
      totalTrips: 1247,
      vehicleType: 'Motor',
      vehicleName: 'Honda Vario 160',
      plateNumber: 'L 5432 BC',
      phone: '+6281234567891',
      lat: -7.2505,
      lng: 112.7388,
    ),
    const DriverModel(
      id: 'drv-02',
      name: 'Rizky Pratama',
      photo: 'assets/images/placeholder.jpg',
      rating: 4.8,
      totalTrips: 893,
      vehicleType: 'Motor',
      vehicleName: 'Yamaha NMAX 155',
      plateNumber: 'L 1278 DE',
      phone: '+6281234567892',
      lat: -7.2612,
      lng: 112.7421,
    ),
    const DriverModel(
      id: 'drv-03',
      name: 'Dian Kartika',
      photo: 'assets/images/placeholder.jpg',
      rating: 4.7,
      totalTrips: 654,
      vehicleType: 'Motor',
      vehicleName: 'Honda PCX 160',
      plateNumber: 'L 8901 FG',
      phone: '+6281234567893',
      lat: -7.2450,
      lng: 112.7350,
    ),
    // ── MOBIL DRIVERS ──
    const DriverModel(
      id: 'drv-04',
      name: 'Budi Santoso',
      photo: 'assets/images/placeholder.jpg',
      rating: 4.9,
      totalTrips: 2156,
      vehicleType: 'Mobil',
      vehicleName: 'Toyota Avanza',
      plateNumber: 'L 1234 AB',
      phone: '+6281234567894',
      lat: -7.2580,
      lng: 112.7400,
    ),
    const DriverModel(
      id: 'drv-05',
      name: 'Sari Dewi Anggraini',
      photo: 'assets/images/placeholder.jpg',
      rating: 4.8,
      totalTrips: 1578,
      vehicleType: 'Mobil',
      vehicleName: 'Daihatsu Xenia',
      plateNumber: 'L 7654 HI',
      phone: '+6281234567895',
      lat: -7.2320,
      lng: 112.7460,
    ),
    const DriverModel(
      id: 'drv-06',
      name: 'Hendra Wijaya',
      photo: 'assets/images/placeholder.jpg',
      rating: 4.9,
      totalTrips: 3021,
      vehicleType: 'Mobil',
      vehicleName: 'Toyota Innova Reborn',
      plateNumber: 'L 4321 JK',
      phone: '+6281234567896',
      lat: -7.2650,
      lng: 112.7350,
    ),
    const DriverModel(
      id: 'drv-07',
      name: 'Eko Prasetyo',
      photo: 'assets/images/placeholder.jpg',
      rating: 4.7,
      totalTrips: 987,
      vehicleType: 'Mobil',
      vehicleName: 'Suzuki Ertiga',
      plateNumber: 'L 6543 LM',
      phone: '+6281234567897',
      lat: -7.2290,
      lng: 112.7380,
    ),
  ];

  static List<DriverModel> byVehicleType(String type) {
    return drivers.where((d) => d.vehicleType == type && d.isAvailable).toList();
  }

  static DriverModel? findById(String id) {
    try {
      return drivers.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }
}
