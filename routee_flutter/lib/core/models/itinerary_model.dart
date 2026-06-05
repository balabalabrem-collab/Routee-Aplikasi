class ItinerarySpot {
  final String id;
  final String name;
  final String image;
  final String timeLabel;
  final String duration;
  final int ticketPrice;
  final String distance;
  final String category;

  const ItinerarySpot({
    required this.id,
    required this.name,
    required this.image,
    required this.timeLabel,
    required this.duration,
    required this.ticketPrice,
    required this.distance,
    required this.category,
  });
}

class ItineraryFood {
  final String name;
  final String image;
  final int price;
  final String area;

  const ItineraryFood({
    required this.name,
    required this.image,
    required this.price,
    required this.area,
  });
}

class ItineraryModel {
  final String terminalName;
  final int hours;
  final List<ItinerarySpot> spots;
  final ItineraryFood food;
  final List<String> transport;

  int get totalTicket => spots.fold(0, (sum, s) => sum + s.ticketPrice);
  int get totalFood => food.price;
  int get totalTransport => 20000;
  int get totalCost => totalTicket + totalFood + totalTransport;

  const ItineraryModel({
    required this.terminalName,
    required this.hours,
    required this.spots,
    required this.food,
    required this.transport,
  });
}
