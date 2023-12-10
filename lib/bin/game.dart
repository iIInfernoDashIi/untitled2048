import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

//https://codereview.stackexchange.com/questions/98830/2048-game-algorithm-in-java

class Game {
  late List<List<int>> grid = [
    [0, 0, 0, 0],
    [0, 0, 0, 0],
    [0, 0, 0, 0],
    [0, 0, 0, 0],
  ];
  List<List<int>> last = [
    [0, 0, 0, 0],
    [0, 0, 0, 0],
    [0, 0, 0, 0],
    [0, 0, 0, 0],
  ];
  bool canUndo = false;
  int score = 0;
  int best = 0;
  bool lose = false;

  Game() {
    generate();
    generate();
  }

  void sync() async {
    final prefs = await SharedPreferences.getInstance();
    best = prefs.getInt('best') ?? 0;
  }

  bool move(Direction dir) {
    bool isMoved = false;
    List<List<int>> lastGrid = [
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ];
    for (int i = 0; i<4; i++) {
      for (int j = 0; j<4; j++) {
        lastGrid[i][j] = grid[i][j];
      }
    }
    for (int i = 0; i<4; i++) {
      List<int> oldGroup = pack(dir, i);
      List<int> newGroup = slide(List.from(oldGroup), dir);
      if (!listEquals(oldGroup, newGroup)) {
        unpack(newGroup, dir, i);
        isMoved = true;
      }
    }
    if (isMoved) {
      save(lastGrid);
      generate();
    }
    if (checkLose()) {
      lose = true;
    }
    return isMoved;
  }

  List<int> slide(List<int> group, Direction dir) {
    int pair = -1;
    
    for (int i = 0; i<4; i++) {
      if (group[i] == 0) {
        continue;
      }
      if (pair == -1) {
        pair = i;
        continue;
      }
      if (group[pair] == group[i]) {
        group[i] *= 2;
        addScore(group[i]);
        group[pair] = 0;
        pair = -1;
        continue;
      }
      pair = i;
    }

    group.removeWhere((element) => element == 0);
    while (group.length<4) {
      group.add(0);
    }

    return group;
  }

  void addScore(int add) async {
    final prefs = await SharedPreferences.getInstance();
    score += add;
    if (best < score) {
      best = score;
      prefs.setInt('best', best);
    }
  }

  List<int> pack(Direction dir, int i) {
    List<int> group = [];

    for (int j = 0; j<4; j++) {
      switch(dir){
        case Direction.up:
          group.add(grid[j][i]);
          break;
        case Direction.down:
          group.add(grid[3-j][i]);
          break;
        case Direction.left:
          group.add(grid[i][j]);
          break;
        case Direction.right:
          group.add(grid[i][3-j]);
          break;
      }
    }

    return group;
  }

  void unpack(List<int> group, Direction dir, int i) {
    for (int j = 0; j<4; j++) {
      switch(dir){
        case Direction.up:
          grid[j][i] = group[j];
          break;
        case Direction.down:
          grid[3-j][i] = group[j];
          break;
        case Direction.left:
          grid[i][j] = group[j];
          break;
        case Direction.right:
          grid[i][3-j] = group[j];
          break;
      }
    }
  }

  void generate() {
    Random rng = Random();
    while(true) {
      int x = rng.nextInt(4);
      int y = rng.nextInt(4);
      if (grid[x][y] == 0) {
        grid[x][y] = (rng.nextInt(2) + 1) * 2;
        return;
      }
    }
  }

  bool checkLose() {
    for (int i = 0; i<4; i++) {
      for (int j = 0; j<4; j++) {
        if (grid[i][j] == 0) return false;
        if (j < 3 && grid[i][j] == grid[i][j+1]) return false;
        if (i < 3 && grid[i][j] == grid[i+1][j]) return false;
      }
    }
    return true;
  }

  void save(List<List<int>> save) {
    last = save;
    canUndo = true;
  }

  void undo() {
    if (canUndo) {
      grid = List.from(last);
      canUndo = false;
    }
  }

  void reset() {
    grid = [
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ];
    last = [
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ];
    generate();
    generate();
    canUndo = false;
    score = 0;
    lose = false;
  }
}

enum Direction {up, down, left, right}