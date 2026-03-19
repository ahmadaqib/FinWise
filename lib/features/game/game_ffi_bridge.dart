import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

const int kGameMaxObstacles = 14;

// Native Structs
final class Obstacle extends Struct {
  @Float()
  external double x;
  @Float()
  external double y;
  @Float()
  external double radius;
  @Bool()
  external bool active;
  @Int32()
  external int type;
}

final class GameState extends Struct {
  @Float()
  external double playerX;
  @Float()
  external double playerY;
  @Float()
  external double playerRadius;
  @Int32()
  external int score;
  @Int32()
  external int health;
  @Bool()
  external bool isGameOver;

  @Array(kGameMaxObstacles)
  external Array<Obstacle> obstacles;
}

// Function Signatures
typedef InitGameNative = Void Function(Pointer<GameState>);
typedef InitGame = void Function(Pointer<GameState>);

typedef UpdateGameNative =
    Void Function(
      Pointer<GameState>,
      Float deltaTime,
      Float inputX,
      Float difficulty,
    );
typedef UpdateGame =
    void Function(
      Pointer<GameState>,
      double deltaTime,
      double inputX,
      double difficulty,
    );

class GameFFIBridge {
  late final DynamicLibrary _lib;

  late final InitGame initGame;
  late final UpdateGame updateGame;

  GameFFIBridge() {
    _lib = _loadLib();

    initGame = _lib
        .lookup<NativeFunction<InitGameNative>>('init_game')
        .asFunction();

    updateGame = _lib
        .lookup<NativeFunction<UpdateGameNative>>('update_game')
        .asFunction();
  }

  DynamicLibrary _loadLib() {
    if (Platform.isAndroid) {
      return DynamicLibrary.open('libgame_engine.so');
    } else if (Platform.isIOS) {
      return DynamicLibrary.process();
    }
    throw UnsupportedError('Platform not supported for Game FFI');
  }

  Pointer<GameState> createGameState() {
    return calloc<GameState>();
  }

  void freeGameState(Pointer<GameState> state) {
    calloc.free(state);
  }
}
