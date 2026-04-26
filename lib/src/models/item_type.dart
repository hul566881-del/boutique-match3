import 'dart:ui';

enum ItemType {
  redBra,
  blackLacePanty,
  whiteGarter,
  purpleCorset,
  pinkNightgown,
}

extension ItemTypeStyle on ItemType {
  Color get color {
    switch (this) {
      case ItemType.redBra:
        return const Color(0xFFE53935);
      case ItemType.blackLacePanty:
        return const Color(0xFF212121);
      case ItemType.whiteGarter:
        return const Color(0xFFF5F5F5);
      case ItemType.purpleCorset:
        return const Color(0xFF8E24AA);
      case ItemType.pinkNightgown:
        return const Color(0xFFEC407A);
    }
  }

  String get shortLabel {
    switch (this) {
      case ItemType.redBra:
        return 'RB';
      case ItemType.blackLacePanty:
        return 'BL';
      case ItemType.whiteGarter:
        return 'WG';
      case ItemType.purpleCorset:
        return 'PC';
      case ItemType.pinkNightgown:
        return 'PN';
    }
  }
}
