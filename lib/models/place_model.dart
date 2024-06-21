import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'place_model.g.dart';

@HiveType(typeId: 0)
class Place extends Equatable {
  @HiveField(0)
  final String placeId;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final num lat;
  @HiveField(3)
  final num lon;

  Place({
    this.placeId = '',
    this.name = 'sahloul',
    this.lat = 36.8008, // Default latitude for Avenue Habib Bourguiba, Tunis
    this.lon = 10.1806, // Default longitude for Avenue Habib Bourguiba, Tunis
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      placeId: json['place_id'] ?? json['placeId'] ?? '123',
      name: json['name'] ?? 'Avenue Habib Bourguiba',
      lat: json['geometry']?['location']?['lat'] ?? json['lat'] ?? 36.8008,
      lon: json['geometry']?['location']?['lng'] ?? json['lon'] ?? 10.1806,
    );
  }

  @override
  List<Object?> get props => [placeId, name, lat, lon];
}
