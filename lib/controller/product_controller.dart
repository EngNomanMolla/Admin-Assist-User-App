import 'dart:convert';
import 'package:flutter_widgets/provider/product_provider.dart';
import 'package:get/get.dart';

class Category {
  final int id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
    );
  }
}

class Product {
  final int id;
  final String name;
  final String categoryId;
  final String size;
  final String material;
  final String color;
  final String quality;
  final String image;
  final String? description;
  final Category category;

  Product({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.size,
    required this.material,
    required this.color,
    required this.quality,
    required this.image,
    this.description,
    required this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      categoryId: json['category_id'].toString(),
      size: json['size'] ?? 'N/A',
      material: json['material'] ?? 'N/A',
      color: json['color'] ?? 'N/A',
      quality: json['quality'] ?? 'N/A',
      image: json['image'],
      description: json['description'],
      category: Category.fromJson(json['category']),
    );
  }
}

class ProductController extends GetxController {
  final ProductProvider _productProvider = ProductProvider();
  
  String selectedCategory = "All";
  String searchQuery = "";
  List<Product> allProducts = [];
  List<Product> filteredProducts = [];
  List<Category> categories = [];
  bool isLoading = false;
  bool isSearching = false;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      isLoading = true;
      update();

      final response = await _productProvider.getProducts('all');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Parse Categories
        categories = (data['categories'] as List)
            .map((cat) => Category.fromJson(cat))
            .toList();
            
        // Parse Products
        allProducts = (data['products'] as List)
            .map((prod) => Product.fromJson(prod))
            .toList();
            
        _applyFilters();
      }
    } catch (e) {
      print("Error fetching products: $e");
    } finally {
      isLoading = false;
      update();
    }
  }

  void changeCategory(String categoryName) {
    selectedCategory = categoryName;
    _applyFilters();
    update();
  }

  void searchProducts(String query) {
    searchQuery = query;
    _applyFilters();
    update();
  }

  void toggleSearch() {
    isSearching = !isSearching;
    if (!isSearching) {
      searchQuery = "";
      _applyFilters();
    }
    update();
  }

  void _applyFilters() {
    List<Product> results = allProducts;

    // Filter by Category
    if (selectedCategory != "All") {
      results = results
          .where((product) => product.category.name == selectedCategory)
          .toList();
    }

    // Filter by Search Query
    if (searchQuery.isNotEmpty) {
      results = results
          .where((product) => 
              product.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
              product.category.name.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }

    filteredProducts = results;
  }
}
