import 'package:learning/core/model/selected_product.dart';
import 'package:learning/features/home_screen/model/product_model.dart' hide Rating;

extension ProductToSelectedProduct on Product {
  SelectedProduct toSelectedProduct() {
    return SelectedProduct(
      id: id,
      title: title,
      price: price,
      description: description,
      category: category,
      image: image,
      rating: rating != null
          ? Rating(rate: rating!.rate, count: rating!.count)
          : null,
    );
  }
}
