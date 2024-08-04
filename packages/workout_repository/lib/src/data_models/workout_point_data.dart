final class WorkoutPointData {
  final double latitude;
  final double longitude;
  final int orderPriority;

  const WorkoutPointData(
      {required this.latitude,
      required this.longitude,
      required this.orderPriority});

  factory WorkoutPointData.fromRow(Map<String, Object?> row) {
    return WorkoutPointData(
      latitude: row['latitude'] as double,
      longitude: row['longitude'] as double,
      orderPriority: row['order_priority'] as int,
    );
  }
}
