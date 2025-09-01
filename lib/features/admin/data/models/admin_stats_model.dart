import '../../domain/entities/admin_stats_entity.dart';

class AdminStatsModel extends AdminStatsEntity {
  const AdminStatsModel({
    required super.totalParticipants,
    required super.totalTickets,
    required super.paidParticipants,
    required super.unpaidParticipants,
    required super.totalRevenue,
  });

  factory AdminStatsModel.fromJson(Map<String, dynamic> json) {
    return AdminStatsModel(
      totalParticipants: json['total_participants'] ?? 0,
      totalTickets: json['total_tickets'] ?? 0,
      paidParticipants: json['paid_participants'] ?? 0,
      unpaidParticipants: json['unpaid_participants'] ?? 0,
      totalRevenue: (json['total_revenue'] ?? 0).toDouble(),
    );
  }
}
