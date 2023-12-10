import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:untitled2048/widgets/hold_button.dart';
import 'package:untitled2048/bin/game.dart';

Map<int, Color> tileColors = {
  0: Colors.blueGrey.shade50,
  2: Colors.blueGrey.shade200,
  4: Colors.blueGrey.shade400,
  8: Colors.yellow.shade400,
  16: Colors.yellow.shade500,
  32: Colors.yellow.shade800,
  64: Colors.deepOrange.shade300,
  128: Colors.deepOrange.shade500,
  256: Colors.deepOrange.shade800,
  512: Colors.red.shade300,
  1024: Colors.red.shade500,
  2048: Colors.red.shade800,
  4096: Colors.grey.shade600,
  8192: Colors.grey.shade800,
};

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {

  Game game = Game();
  bool moved = false;

  Future<void> showLoseDialog() {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Вы проиграли!'),
          content: Text('Ваш счёт: ${game.score}'),
          actions: <Widget>[
            TextButton(
              child: const Text('Попробовать ещё раз'),
              onPressed: () {
                game.reset();
                setState(() {});
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    game.sync();
    setState(() {});

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: const Icon(Icons.grid_view_rounded),
        title: const Text('2048'),
        actions: [
          IconButton(
            onPressed: game.canUndo ?
              () {
                game.undo();
                setState(() {});
              }
              : null,
            icon: const Icon(Icons.undo_rounded),
          ),
          HoldButton(
            icon: const Icon(Icons.refresh),
            onHold: () {
              game.reset();
              setState(() {});
            },
          ),
        ],
      ),
      body: RawKeyboardListener(
        autofocus: true,
        onKey: (event) {
          if (event.runtimeType == RawKeyDownEvent) {
            if (!game.lose) {
              if (event.physicalKey == PhysicalKeyboardKey.keyW) {
                game.move(Direction.up);
                if (game.lose) showLoseDialog();
                setState(() {});
              }
              if (event.physicalKey == PhysicalKeyboardKey.keyS) {
                game.move(Direction.down);
                if (game.lose) showLoseDialog();
                setState(() {});
              }
              if (event.physicalKey == PhysicalKeyboardKey.keyA) {
                game.move(Direction.left);
                if (game.lose) showLoseDialog();
                setState(() {});
              }
              if (event.physicalKey == PhysicalKeyboardKey.keyD) {
                game.move(Direction.right);
                if (game.lose) showLoseDialog();
                setState(() {});
              }
            }
          }
        },
        focusNode: FocusNode(),
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(48),
          child: Center(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      game.score.toString(),
                      style: const TextStyle(
                        fontSize: 48,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.emoji_events_rounded),
                        Text(
                          game.best.toString(),
                          style: const TextStyle(
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                AspectRatio(
                  aspectRatio: 1,
                  child: GestureDetector(
                    onVerticalDragUpdate: ((details) {
                      if (moved) return;
                      if (details.primaryDelta !< 0) {
                        if (game.move(Direction.up)) moved = true;
                      }
                      if (details.primaryDelta !> 0) {
                        if (game.move(Direction.down)) moved = true;
                      }
                      if (game.lose) showLoseDialog();
                      setState(() {});
                    }),
                    onVerticalDragEnd: ((details) {
                      moved = false;
                    }),
                    onHorizontalDragUpdate: ((details) {
                      if (moved) return;
                      if (details.primaryDelta !< 0) {
                        if (game.move(Direction.left)) moved = true;
                      }
                      if (details.primaryDelta !> 0) {
                        if (game.move(Direction.right)) moved = true;
                      }
                      if (game.lose) showLoseDialog();
                      setState(() {});
                    }),
                    onHorizontalDragEnd: ((details) {
                      moved = false;
                    }),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 4.0,
                        crossAxisSpacing: 4.0,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: 16,
                      itemBuilder: (BuildContext context, index) {
                        var value = game.grid[index ~/ 4][index % 4];
                        return AnimatedContainer(
                          curve: Curves.bounceOut,
                          duration: const Duration(milliseconds: 150),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: tileColors[value] ?? Colors.black,
                            borderRadius: BorderRadius.circular(8)
                          ),
                          child: (value != 0) ? Text(
                            value.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                            ),
                          ) : null,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}