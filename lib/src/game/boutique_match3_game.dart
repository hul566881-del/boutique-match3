import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../logic/board_initializer.dart';
import '../models/game_board_state.dart';
import '../models/item_type.dart';
import '../state/game_state_controller.dart';
import 'components/grid_tile_component.dart';

class BoutiqueMatch3Game extends FlameGame {
  BoutiqueMatch3Game();

  final BoardInitializer _boardInitializer = BoardInitializer();
  late final GameStateController _stateController;
  final List<GridTileComponent> _tiles = [];
  Offset? _swipeStart;
  Offset? _swipeCurrent;
  bool _isAnimating = false;
  double _tileSize = 0;
  double _boardStartX = 0;
  double _boardStartY = 0;
  double _boardSide = 0;

  static const double _boardPadding = 16;
  static const double _swapDurationSec = 0.16;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    camera.viewfinder.anchor = Anchor.topLeft;
    _stateController = GameStateController(_boardInitializer.createInitialBoard());
    _buildBoardVisuals(_stateController.value);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isLoaded) {
      _buildBoardVisuals(_stateController.value);
    }
  }

  void _buildBoardVisuals(GameBoardState state) {
    for (final tile in _tiles) {
      tile.removeFromParent();
    }
    _tiles.clear();

    final side = size.x < size.y ? size.x : size.y;
    _boardSide = side - (_boardPadding * 2);
    _tileSize = _boardSide / state.size;
    _boardStartX = (size.x - _boardSide) / 2;
    _boardStartY = (size.y - _boardSide) / 2;

    for (var row = 0; row < state.size; row++) {
      for (var col = 0; col < state.size; col++) {
        final tile = GridTileComponent(
          item: state.items[row][col],
          tileSize: _tileSize,
        )
          ..position = Vector2(
            _boardStartX + col * _tileSize,
            _boardStartY + row * _tileSize,
          );
        _tiles.add(tile);
        add(tile);
      }
    }
  }

  void onSwipeStart(Offset localPosition) {
    if (_isAnimating || !isLoaded) {
      return;
    }
    _swipeStart = localPosition;
    _swipeCurrent = localPosition;
  }

  void onSwipeUpdate(Offset localPosition) {
    if (_swipeStart == null || _isAnimating || !isLoaded) {
      return;
    }
    _swipeCurrent = localPosition;
  }

  Future<void> onSwipeEnd() async {
    if (_isAnimating || !isLoaded || _swipeStart == null || _swipeCurrent == null) {
      _swipeStart = null;
      _swipeCurrent = null;
      return;
    }

    final state = _stateController.value;
    final fromCell = _positionToCell(_swipeStart!, state.size);
    final start = _swipeStart!;
    final end = _swipeCurrent!;
    _swipeStart = null;
    _swipeCurrent = null;
    if (fromCell == null) {
      return;
    }

    final toCell = _resolveNeighborCell(
      row: fromCell.$1,
      col: fromCell.$2,
      start: start,
      end: end,
      size: state.size,
    );
    if (toCell == null) {
      return;
    }

    await _attemptSwap(
      fromRow: fromCell.$1,
      fromCol: fromCell.$2,
      toRow: toCell.$1,
      toCol: toCell.$2,
    );
  }

  (int, int)? _resolveNeighborCell({
    required int row,
    required int col,
    required Offset start,
    required Offset end,
    required int size,
  }) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final threshold = _tileSize * 0.28;
    if (dx.abs() < threshold && dy.abs() < threshold) {
      return null;
    }

    if (dx.abs() >= dy.abs()) {
      final nextCol = dx > 0 ? col + 1 : col - 1;
      if (nextCol < 0 || nextCol >= size) {
        return null;
      }
      return (row, nextCol);
    }

    final nextRow = dy > 0 ? row + 1 : row - 1;
    if (nextRow < 0 || nextRow >= size) {
      return null;
    }
    return (nextRow, col);
  }

  (int, int)? _positionToCell(Offset position, int size) {
    if (position.dx < _boardStartX ||
        position.dy < _boardStartY ||
        position.dx >= _boardStartX + _boardSide ||
        position.dy >= _boardStartY + _boardSide) {
      return null;
    }

    final col = ((position.dx - _boardStartX) / _tileSize).floor();
    final row = ((position.dy - _boardStartY) / _tileSize).floor();
    if (row < 0 || col < 0 || row >= size || col >= size) {
      return null;
    }
    return (row, col);
  }

  Future<void> _attemptSwap({
    required int fromRow,
    required int fromCol,
    required int toRow,
    required int toCol,
  }) async {
    final state = _stateController.value;
    final tileA = _findTile(fromRow, fromCol);
    final tileB = _findTile(toRow, toCol);
    if (tileA == null || tileB == null) {
      return;
    }

    _isAnimating = true;
    final originalA = tileA.position.clone();
    final originalB = tileB.position.clone();

    await Future.wait([
      _animateMove(tileA, originalB),
      _animateMove(tileB, originalA),
    ]);

    final valid = _wouldCreateAnyMatchAfterSwap(
      state: state,
      row1: fromRow,
      col1: fromCol,
      row2: toRow,
      col2: toCol,
    );

    if (!valid) {
      await Future.wait([
        _animateMove(tileA, originalA),
        _animateMove(tileB, originalB),
      ]);
      _isAnimating = false;
      return;
    }

    final nextState = _swapState(
      state: state,
      row1: fromRow,
      col1: fromCol,
      row2: toRow,
      col2: toCol,
    );
    _stateController.setBoard(nextState);
    _buildBoardVisuals(nextState);
    _isAnimating = false;
  }

  GridTileComponent? _findTile(int row, int col) {
    for (final tile in _tiles) {
      if (tile.item.row == row && tile.item.col == col) {
        return tile;
      }
    }
    return null;
  }

  Future<void> _animateMove(GridTileComponent tile, Vector2 target) {
    final completer = Completer<void>();
    tile.add(
      MoveToEffect(
        target,
        EffectController(duration: _swapDurationSec, curve: Curves.easeOutCubic),
        onComplete: completer.complete,
      ),
    );
    return completer.future;
  }

  bool _wouldCreateAnyMatchAfterSwap({
    required GameBoardState state,
    required int row1,
    required int col1,
    required int row2,
    required int col2,
  }) {
    final types = <List<ItemType>>[
      for (final row in state.items) [for (final item in row) item.type],
    ];

    final temp = types[row1][col1];
    types[row1][col1] = types[row2][col2];
    types[row2][col2] = temp;

    return _hasAnyMatch(types, state.size);
  }

  bool _hasAnyMatch(List<List<ItemType>> types, int size) {
    for (var row = 0; row < size; row++) {
      var run = 1;
      for (var col = 1; col < size; col++) {
        if (types[row][col] == types[row][col - 1]) {
          run++;
        } else {
          run = 1;
        }
        if (run >= 3) {
          return true;
        }
      }
    }

    for (var col = 0; col < size; col++) {
      var run = 1;
      for (var row = 1; row < size; row++) {
        if (types[row][col] == types[row - 1][col]) {
          run++;
        } else {
          run = 1;
        }
        if (run >= 3) {
          return true;
        }
      }
    }
    return false;
  }

  GameBoardState _swapState({
    required GameBoardState state,
    required int row1,
    required int col1,
    required int row2,
    required int col2,
  }) {
    final copied = [
      for (final row in state.items) [...row],
    ];
    final first = copied[row1][col1];
    final second = copied[row2][col2];

    copied[row1][col1] = second;
    copied[row2][col2] = first;

    final normalized = List.generate(state.size, (row) {
      return List.generate(state.size, (col) {
        final current = copied[row][col];
        return current.copyWith(row: row, col: col);
      });
    });

    return GameBoardState(size: state.size, items: normalized);
  }

  @override
  Color backgroundColor() => const Color(0xFF111015);

  @override
  void onRemove() {
    _stateController.dispose();
    super.onRemove();
  }
}
