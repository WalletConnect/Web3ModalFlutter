class GridListItemModel {
  final String image;
  final String title;
  final String? description;
  final void Function() onSelect;

  GridListItemModel({
    required this.image,
    required this.title,
    this.description,
    required this.onSelect,
  });
}
