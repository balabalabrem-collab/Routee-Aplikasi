import '../models/transport_model.dart';

class TransportData {
  static final List<TransportModel> options = [
    TransportModel(
      id: 'motorbike',
      icon: '🛵',
      name: 'Motor',
      image: 'assets/images/motor.jpg',
      price: 'Rp 70.000 / hari',
      desc: 'Fleksibel, mudah parkir di gang sempit kawasan heritage. Cocok untuk solo traveler atau pasangan.',
      pros: ['Hemat biaya', 'Mudah parkir', 'Bebas macet', 'Fleksibel rute'],
      cons: ['Kapasitas 2 orang', 'Rentan cuaca', 'Tidak ada AC'],
      colorHex: '#6D4C2A',
      badge: 'Paling Hemat',
    ),
    TransportModel(
      id: 'car',
      icon: '🚗',
      name: 'Mobil + Driver',
      image: 'assets/images/mobil-driver.jpg',
      price: 'Rp 300.000 / hari',
      desc: 'Nyaman untuk keluarga atau rombongan. Driver berpengalaman tahu rute terbaik kota lama.',
      pros: ['Nyaman & AC', 'Kapasitas 4–6 orang', 'Driver berpengalaman', 'Aman'],
      cons: ['Biaya lebih tinggi', 'Sulit parkir di area sempit', 'Tergantung driver'],
      colorHex: '#4A5568',
      badge: 'Populer',
    ),
    TransportModel(
      id: 'tour',
      icon: '🏆',
      name: 'Private Tour',
      image: 'assets/images/private-tour.jpg',
      price: 'Mulai Rp 500.000',
      desc: 'Paket lengkap dengan pemandu berlisensi, kendaraan, dan tiket destinasi. Pengalaman premium!',
      pros: ['Pemandu berlisensi', 'All-inclusive', 'Jadwal fleksibel', 'Foto & cerita eksklusif'],
      cons: ['Biaya tertinggi', 'Perlu booking H-1', 'Jadwal mungkin terbatas'],
      colorHex: '#E8A838',
      badge: 'Premium',
    ),
  ];
}
