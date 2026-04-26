import 'package:flutter/foundation.dart';

import '../models/game_board_state.dart';

class GameStateController extends ValueNotifier<GameBoardState> {
  GameStateController(GameBoardState initialState) : super(initialState);

  void setBoard(GameBoardState nextState) {
    value = nextState;
  }
}
