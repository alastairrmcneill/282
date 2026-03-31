import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:two_eight_two/models/models.dart';

class CreatePostMunroTile extends StatelessWidget {
  final Munro munro;
  final VoidCallback onRemove;

  const CreatePostMunroTile({super.key, required this.munro, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: munro.pictureURL,
            width: 48,
            height: 48,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              width: 48,
              height: 48,
              color: Colors.grey.shade200,
            ),
            errorWidget: (context, url, error) => Container(
              width: 48,
              height: 48,
              color: Colors.grey.shade200,
              child: const Icon(Icons.terrain, color: Colors.grey),
            ),
          ),
        ),
        title: Text(
          munro.name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Text(
          '${munro.meters}m • ${munro.area}',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        trailing: GestureDetector(
          onTap: onRemove,
          child: Icon(Icons.close, color: Colors.grey.shade400, size: 20),
        ),
      ),
    );
  }
}
