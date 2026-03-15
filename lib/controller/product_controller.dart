import 'package:get/get.dart';

class Product {
  final String title;
  final String subTitle;
  final String material;
  final String size;
  final String color;
  final String image;

  Product({
    required this.title,
    required this.subTitle,
    required this.material,
    required this.size,
    required this.color,
    required this.image,
  });
}

class ProductController extends GetxController {
  String selectedCategory = "Men's";

  List<Product> products = [
    Product(
      title: 'Full Sleeve Panjabi',
      subTitle: 'Premium Look',
      material: 'Cotton Fabric',
      size: '38',
      color: 'Printed',
      image: 'assets/images/3rdpic.png',
    ),
    Product(
      title: 'Silk Panjabi',
      subTitle: 'Export Quality',
      material: 'Silk Fabric',
      size: '40',
      color: 'Deep Blue',
      image: 'assets/images/5thpic.png',
    ),
    Product(
      title: 'Premium Shirt',
      subTitle: 'Office Wear',
      material: 'Linen',
      size: 'L',
      color: 'White',
      image: 'assets/images/5thpic.png',
    ),
  ];

  void changeCategory(String category) {
    selectedCategory = category;

    update();
  }
}
