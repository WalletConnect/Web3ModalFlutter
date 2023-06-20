class GridListItemModel<T> {
  final String image;
  final String id;
  final String title;
  final String? description;
  final T data;

  GridListItemModel({
    required this.image,
    required this.id,
    required this.title,
    this.description,
    required this.data,
  });
}
