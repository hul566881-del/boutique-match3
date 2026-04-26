import 'dart:math';

import '../models/game_board_state.dart';
import '../models/grid_item.dart';
import '../models/item_type.dart';

class BoardInitializer {
  BoardInitializer({Random? random}) : _random = random ?? Random();

  final Random _random;
  static const int defaultGridSize = 8;

  GameBoardState createInitialBoard({int size = defaultGridSize}) {
    final matrix = List.generate(
      size,
      (_) => List<GridItem?>.filled(size, null),
    );

    for (var row = 0; row < size; row++) {
      for (var col = 0; col < size; col++) {
        final type = _pickTypeAvoidingImmediateMatch(matrix, row, col);
        matrix[row][col] = GridItem(row: row, col: col, type: type);
      }
    }

    return GameBoardState(
      size: size,
      items: matrix
          .map((row) => row.map((cell) => cell!).toList(growable: false))
          .toList(growable: false),
    );
  }

  ItemType _pickTypeAvoidingImmediateMatch(
    List<List<GridItem?>> matrix,
    int row,
    int col,
  ) {
    final allTypes = ItemType.values.toList(growable: false);
    allTypes.shuffle(_random);

    for (final candidate in allTypes) {
      if (!_createsHorizontal3(matrix, row, col, candidate) &&
          !_createsVertical3(matrix, row, col, candidate)) {
        return candidate;
      }
    }

    return allTypes.first;
  }

  bool _createsHorizontal3(
    List<List<GridItem?>> matrix,
    int row,
    int col,
    ItemType candidate,
  ) {
    if (col < 2) {
      return false;
    }

    final left1 = matrix[row][col - 1];
    final left2 = matrix[row][col - 2];
    return left1?.type == candidate && left2?.type == candidate;
  }

  bool _createsVertical3(
    List<List<GridItem?>> matrix,
    int row,
    int col,
    ItemType candidate,
  ) {
    if (row < 2) {
      return false;
    }

    final up1 = matrix[row - 1][col];
    final up2 = matrix[row - 2][col];
    return up1?.type == candidate && up2?.type == candidate;
  }
}
