class Statistics {
  final int totalUsers;
  final int totalDestinations;
  final int totalReviews;
  final int totalEvents;
  final double averageRating;
  final int activeUsers;
  final int blockedUsers;
  final Map<String, int> destinationsByCategory;
  final Map<String, int> usersByRole;
  final DateTime generatedAt;

  Statistics({
    required this.totalUsers,
    required this.totalDestinations,
    required this.totalReviews,
    required this.totalEvents,
    required this.averageRating,
    required this.activeUsers,
    required this.blockedUsers,
    required this.destinationsByCategory,
    required this.usersByRole,
    required this.generatedAt,
  });

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      totalUsers: json['totalUsers'] ?? 0,
      totalDestinations: json['totalDestinations'] ?? 0,
      totalReviews: json['totalReviews'] ?? 0,
      totalEvents: json['totalEvents'] ?? 0,
      averageRating: (json['averageRating'] ?? 0.0).toDouble(),
      activeUsers: json['activeUsers'] ?? 0,
      blockedUsers: json['blockedUsers'] ?? 0,
      destinationsByCategory: Map<String, int>.from(json['destinationsByCategory'] ?? {}),
      usersByRole: Map<String, int>.from(json['usersByRole'] ?? {}),
      generatedAt: DateTime.parse(json['generatedAt'] ?? DateTime.now().toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalUsers': totalUsers,
      'totalDestinations': totalDestinations,
      'totalReviews': totalReviews,
      'totalEvents': totalEvents,
      'averageRating': averageRating,
      'activeUsers': activeUsers,
      'blockedUsers': blockedUsers,
      'destinationsByCategory': destinationsByCategory,
      'usersByRole': usersByRole,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }
}
