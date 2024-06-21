import 'package:equatable/equatable.dart';

class Price extends Equatable {
  final int id;
  final String price;

  Price({
    required this.id,
    required this.price,
  });

  @override
  List<Object?> get props => [id, price];

  static List<Price> prices = [
    Price(id: 1, price: '10 dt'),
    Price(id: 2, price: '20 dt'),
    Price(id: 3, price: '50 dt'),
  ];
}
