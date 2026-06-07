class PaymentModel {
  final String id;
  final String driverId;
  final String vehicleType;
  final String method;
  final int rentalPrice;
  final int serviceFee;
  final int totalAmount;
  final String status; // 'pending', 'processing', 'success', 'failed'
  final DateTime createdAt;
  final String referenceNumber;
  final int durationHours;

  const PaymentModel({
    required this.id,
    required this.driverId,
    required this.vehicleType,
    required this.method,
    required this.rentalPrice,
    required this.serviceFee,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.referenceNumber,
    required this.durationHours,
  });
}
