import 'grid_item.dart';

class GameBoardState {
  const GameBoardState({
    required this.size,
    required this.items,
  });

  final int size;
  final List<List<GridItem>> items;
}
