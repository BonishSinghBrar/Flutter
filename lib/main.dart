import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bonish Snake Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const SnakeGame(),
    );
  }
}

class SnakeGame extends StatefulWidget {
  const SnakeGame({Key? key}) : super(key: key);

  @override
  _SnakeGameState createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame> {
  static const int rows = 50;
  static const int columns = 30;
  static const double cellSize = 15.0;

  late List<Point<int>> snake;
  late Point<int> food;
  late Direction direction;
  late Timer timer;
  int score = 0; // Variable to track the score

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    snake = [Point(columns ~/ 2, rows ~/ 2)];
    food = Point(Random().nextInt(columns), Random().nextInt(rows));
    direction = Direction.right;
    timer = Timer.periodic(const Duration(milliseconds: 20), (_) => moveSnake());
  }

  void moveSnake() {
    setState(() {
      final Point<int> newHead = getNextHead();
      if (isGameOver(newHead)) {
        timer.cancel();
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Game Over'),
            content: Text('Your Score: $score\nWould you like to play again?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  startGame();
                  score = 0; // Reset the score when starting a new game
                },
                child: const Text('Yes'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).pop();
                },
                child: const Text('No'),
              ),
            ],
          ),
        );
      } else {
        snake.insert(0, newHead);
        if (newHead == food) {
          generateNewFood();
          score++; // Increase the score when the snake eats food
        } else {
          snake.removeLast();
        }
      }
    });
  }

  Point<int> getNextHead() {
    final Point<int> head = snake.first;
    switch (direction) {
      case Direction.up:
        return Point(head.x, (head.y - 1 + rows) % rows);
      case Direction.down:
        return Point(head.x, (head.y + 1) % rows);
      case Direction.left:
        return Point((head.x - 1 + columns) % columns, head.y);
      case Direction.right:
        return Point((head.x + 1) % columns, head.y);
    }
  }

  bool isGameOver(Point<int> newHead) {
    if (snake.contains(newHead) || newHead.x < 0 || newHead.x >= columns || newHead.y < 0 || newHead.y >= rows) {
      return true;
    }
    return false;
  }

  void generateNewFood() {
    food = Point(Random().nextInt(columns), Random().nextInt(rows));
  }

  void changeDirection(Direction newDirection) {
    if ((newDirection == Direction.up && direction != Direction.down) ||
        (newDirection == Direction.down && direction != Direction.up) ||
        (newDirection == Direction.left && direction != Direction.right) ||
        (newDirection == Direction.right && direction != Direction.left)) {
      direction = newDirection;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bonish Snake Game'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Text(
              'Score: $score',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                if (details.delta.dy > 0) {
                  changeDirection(Direction.down);
                } else if (details.delta.dy < 0) {
                  changeDirection(Direction.up);
                }
              },
              onHorizontalDragUpdate: (details) {
                if (details.delta.dx > 0) {
                  changeDirection(Direction.right);
                } else if (details.delta.dx < 0) {
                  changeDirection(Direction.left);
                }
              },
              child: Container(
                color: Colors.black,
                child: GridView.builder(
                  padding: EdgeInsets.all(2.0),
                  itemCount: rows * columns,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    childAspectRatio: 1.0,
                  ),
                  itemBuilder: (context, index) {
                    final int x = index % columns;
                    final int y = index ~/ columns;
                    final Point<int> position = Point(x, y);

                    Color color;
                    if (snake.contains(position)) {
                      color = Colors.red;
                    } else if (food == position) {
                      color = Colors.blue;
                    } else {
                      color = Colors.black;
                    }

                    return Container(
                      margin: EdgeInsets.all(1.0),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum Direction { up, down, left, right }
