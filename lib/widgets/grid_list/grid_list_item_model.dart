class GridListItemModel {
  final String image;
  final String id;
  final String title;
  final String? description;
  final void Function() onSelect;
  final bool installed;

  GridListItemModel({
    required this.image,
    required this.id,
    required this.title,
    this.description,
    required this.onSelect,
    required this.installed,
  });
}
