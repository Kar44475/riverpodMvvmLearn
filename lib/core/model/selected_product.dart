import 'package:json_annotation/json_annotation.dart';

part 'selected_product.g.dart';

@JsonSerializable()
class SelectedProduct {
  final int ?id;
  final String? title;
  final double ? price;
  final String ? description;
  final String ?category;
  final String ?image;
  final Rating ?rating;

  SelectedProduct({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    required this.rating,
  });
  factory SelectedProduct.fromJson(Map<String, dynamic> json) => _$SelectedProductFromJson(json);
  Map<String, dynamic> toJson() => _$SelectedProductToJson(this);
}

@JsonSerializable()
class Rating {
  final double rate;
  final int count;
  Rating({required this.rate, required this.count});

  factory Rating.fromJson(Map<String,dynamic> json)=> _$RatingFromJson(json);
  Map<String,dynamic> toJson()=>_$RatingToJson(this);
}

