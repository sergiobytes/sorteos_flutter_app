class AdminStatsEntity {
  final int totalParticipants;
  final int totalTickets;
  final int paidParticipants;
  final int unpaidParticipants;
  final double totalRevenue;

  const AdminStatsEntity({
    required this.totalParticipants,
    required this.totalTickets,
    required this.paidParticipants,
    required this.unpaidParticipants,
    required this.totalRevenue,
  });
}
