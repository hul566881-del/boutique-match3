import 'item_type.dart';

class GridItem {
  GridItem({
    required this.row,
    required this.col,
    required this.type,
  });

  final int row;
  final int col;
  final ItemType type;

  GridItem copyWith({
    int? row,
    int? col,
    ItemType? type,
  }) {
    return GridItem(
      row: row ?? this.row,
      col: col ?? this.col,
      type: type ?? this.type,
    );
  }
}
