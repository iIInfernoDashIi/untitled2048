import 'package:flutter/material.dart';

class Tile {
  final int x;
  final int y;
  late int value;

  late Animation<double> animatedX;
  late Animation<double> animatedY;
  late Animation<int> animatedValue;
  late Animation<double> scale;

  Tile(this.x, this.y, this.value) {

  }

  Tile.empty(this.x, this.y) {
    value = 0;
  }
}

class EmptyTile extends Tile {
  EmptyTile(int x, int y) : super(x, y, 0);
}