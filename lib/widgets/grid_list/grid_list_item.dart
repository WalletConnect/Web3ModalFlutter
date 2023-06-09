import 'package:flutter/material.dart';

class GridListItem extends StatelessWidget {
  const GridListItem({
    super.key,
    required this.title,
    required this.onSelect,
    required this.child,
    this.description,
  });

  final String title;
  final String? description;
  final void Function() onSelect;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelect,
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            child,
            const SizedBox(height: 4.0),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: const TextStyle(
                fontSize: 12.0,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2.0),
            Text(
              description ?? '',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.fade,
              style: const TextStyle(
                fontSize: 12.0,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
