// TODO this class shouldn't be needed
class GridItem<T> {
  final String image;
  final String id;
  final String title;
  final T data;

  GridItem({
    required this.image,
    required this.id,
    required this.title,
    required this.data,
  });

  GridItem<T> copyWith({
    String? image,
    String? id,
    String? title,
    T? data,
  }) {
    return GridItem<T>(
      image: image ?? this.image,
      id: id ?? this.id,
      title: title ?? this.title,
      data: data ?? this.data,
    );
  }
}
