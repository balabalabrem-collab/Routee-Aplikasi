import 'itinerary_model.dart';

class TerminalModel {
  final String id;
  final String name;
  final String icon;
  final List<String> transport;
  final List<ItinerarySpot> spots;
  final ItineraryFood foodRec;
  final double lat;
  final double lng;

  const TerminalModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.transport,
    required this.spots,
    required this.foodRec,
    required this.lat,
    required this.lng,
  });
}
