// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selected_product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SelectedProduct _$SelectedProductFromJson(Map<String, dynamic> json) =>
    SelectedProduct(
      id: (json['id'] as num?)?.toInt(),
      title: json['title'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      description: json['description'] as String?,
      category: json['category'] as String?,
      image: json['image'] as String?,
      rating: json['rating'] == null
          ? null
          : Rating.fromJson(json['rating'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SelectedProductToJson(SelectedProduct instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'price': instance.price,
      'description': instance.description,
      'category': instance.category,
      'image': instance.image,
      'rating': instance.rating,
    };

Rating _$RatingFromJson(Map<String, dynamic> json) => Rating(
  rate: (json['rate'] as num).toDouble(),
  count: (json['count'] as num).toInt(),
);

Map<String, dynamic> _$RatingToJson(Rating instance) => <String, dynamic>{
  'rate': instance.rate,
  'count': instance.count,
};
