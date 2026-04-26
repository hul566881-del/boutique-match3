import 'dart:ui';

import 'package:flame/components.dart';

import '../../models/grid_item.dart';
import '../../models/item_type.dart';

class GridTileComponent extends PositionComponent {
  GridTileComponent({
    required this.item,
    required this.tileSize,
  }) : super(
          size: Vector2.all(tileSize),
          anchor: Anchor.topLeft,
        );

  final GridItem item;
  final double tileSize;

  static final Paint _cellPaint = Paint()..color = const Color(0xFF2B2930);
  static final Paint _framePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1
    ..color = const Color(0x66474650);

  @override
  void render(Canvas canvas) {
    final cellRect = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawRect(cellRect, _cellPaint);
    canvas.drawRect(cellRect, _framePaint);

    final innerPadding = tileSize * 0.14;
    final tokenRect = Rect.fromLTWH(
      innerPadding,
      innerPadding,
      size.x - (innerPadding * 2),
      size.y - (innerPadding * 2),
    );

    final tokenPaint = Paint()..color = item.type.color;
    canvas.drawRRect(
      RRect.fromRectAndRadius(tokenRect, Radius.circular(tileSize * 0.16)),
      tokenPaint,
    );
  }
}
