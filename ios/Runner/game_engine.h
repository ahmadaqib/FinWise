#ifndef GAME_ENGINE_H
#define GAME_ENGINE_H

#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

#if defined(_WIN32)
#define FFI_EXPORT __declspec(dllexport)
#else
#define FFI_EXPORT __attribute__((visibility("default"))) __attribute__((used))
#endif

#define MAX_OBSTACLES 14

typedef struct {
    float x;
    float y;
    float radius;
    bool active;
    int type; // 0: Bonus, 1: Damage, 2: Fast Damage, 3: Rare Bonus
} Obstacle;

typedef struct {
    float playerX;
    float playerY;
    float playerRadius;
    int score;
    int health;
    bool isGameOver;
    Obstacle obstacles[MAX_OBSTACLES];
} GameState;

// FFI Exports
FFI_EXPORT void init_game(GameState* state);
FFI_EXPORT void update_game(GameState* state, float deltaTime, float inputX, float difficulty);
FFI_EXPORT bool check_collision(float x1, float y1, float r1, float x2, float y2, float r2);

#ifdef __cplusplus
}
#endif

#endif // GAME_ENGINE_H
