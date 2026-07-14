class CategoryModel {
  final int id;
  final String name;
  final String image;
  final int parentId;
  final int moduleId;
  final String slug;
  final int productsCount;
  final List<CategoryModel> childes;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.image,
    required this.parentId,
    required this.moduleId,
    required this.slug,
    required this.productsCount,
    required this.childes,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final children = (json['childes'] as List?)
            ?.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const <CategoryModel>[];

    return CategoryModel(
      id: (json['id'] ?? 0) as int,
      name: (json['name'] ?? '').toString(),
      image: (json['image'] ?? '').toString(),
      parentId: (json['parent_id'] ?? 0) as int,
      moduleId: (json['module_id'] ?? 0) as int,
      slug: (json['slug'] ?? '').toString(),
      productsCount: (json['products_count'] ?? 0) as int,
      childes: children,
    );
  }
}

