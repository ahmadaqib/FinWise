#include "game_engine.h"
#include <math.h>
#include <stdlib.h>

static float g_spawn_timer = 0.0f;

static float clampf(float value, float min, float max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
}

static float random01() {
    return (float)rand() / (float)RAND_MAX;
}

FFI_EXPORT void init_game(GameState* state) {
    state->playerX = 0.5f; // Normalized 0.0 to 1.0
    state->playerY = 0.8f;
    state->playerRadius = 0.05f;
    state->score = 0;
    state->health = 100;
    state->isGameOver = false;

    for (int i = 0; i < MAX_OBSTACLES; i++) {
        state->obstacles[i].active = false;
    }

    g_spawn_timer = 0.0f;
}

FFI_EXPORT bool check_collision(float x1, float y1, float r1, float x2, float y2, float r2) {
    float dx = x1 - x2;
    float dy = y1 - y2;
    float distance = sqrtf(dx * dx + dy * dy);
    return distance < (r1 + r2);
}

FFI_EXPORT void update_game(GameState* state, float deltaTime, float inputX, float difficulty) {
    if (state->isGameOver) return;

    difficulty = clampf(difficulty, 0.0f, 1.0f);
    float effectiveDifficulty = 0.35f + (difficulty * 0.95f);

    // Keep player fully inside screen even during extreme swipe input.
    float minPlayerX = state->playerRadius;
    float maxPlayerX = 1.0f - state->playerRadius;
    if (maxPlayerX < minPlayerX) {
        maxPlayerX = minPlayerX;
    }

    float targetX = clampf(inputX, minPlayerX, maxPlayerX);
    float follow = clampf(deltaTime * 14.0f, 0.0f, 1.0f);
    state->playerX += (targetX - state->playerX) * follow;
    state->playerX = clampf(state->playerX, minPlayerX, maxPlayerX);

    // Spawn logic (simplified for FFI)
    g_spawn_timer += deltaTime;
    
    float spawnInterval = 1.65f / (1.0f + effectiveDifficulty * 1.3f);
    spawnInterval = clampf(spawnInterval, 0.34f, 1.3f);

    if (g_spawn_timer > spawnInterval) {
        for (int i = 0; i < MAX_OBSTACLES; i++) {
            if (!state->obstacles[i].active) {
                state->obstacles[i].active = true;
                state->obstacles[i].y = -0.12f;

                int roll = rand() % 100;
                if (roll < 22) {
                    state->obstacles[i].type = 0; // Bonus
                    state->obstacles[i].radius = 0.035f;
                } else if (roll < 63) {
                    state->obstacles[i].type = 1; // Damage
                    state->obstacles[i].radius = 0.042f;
                } else if (roll < 88) {
                    state->obstacles[i].type = 2; // Fast damage
                    state->obstacles[i].radius = 0.034f;
                } else {
                    state->obstacles[i].type = 3; // Rare bonus
                    state->obstacles[i].radius = 0.030f;
                }

                float minObstacleX = state->obstacles[i].radius;
                float maxObstacleX = 1.0f - state->obstacles[i].radius;
                float rangeX = maxObstacleX - minObstacleX;
                state->obstacles[i].x = minObstacleX + (random01() * rangeX);
                break;
            }
        }
        g_spawn_timer = 0.0f;
    }

    // Update obstacles
    float baseSpeed = 0.33f + (effectiveDifficulty * 0.18f);
    for (int i = 0; i < MAX_OBSTACLES; i++) {
        if (state->obstacles[i].active) {
            float obstacleSpeed = baseSpeed;

            if (state->obstacles[i].type == 0) {
                obstacleSpeed *= 0.82f;
            } else if (state->obstacles[i].type == 2) {
                obstacleSpeed *= 1.6f;
            } else if (state->obstacles[i].type == 3) {
                obstacleSpeed *= 1.25f;
            }

            state->obstacles[i].y += obstacleSpeed * deltaTime;

            if (state->obstacles[i].type == 2 || state->obstacles[i].type == 3) {
                float wobbleFrequency = state->obstacles[i].type == 2 ? 16.0f : 9.0f;
                float wobbleAmplitude = state->obstacles[i].type == 2 ? 0.26f : 0.14f;
                float wobble = sinf((state->obstacles[i].y + (float)i * 0.17f) * wobbleFrequency);
                state->obstacles[i].x += wobble * wobbleAmplitude * deltaTime;

                float minObstacleX = state->obstacles[i].radius;
                float maxObstacleX = 1.0f - state->obstacles[i].radius;
                state->obstacles[i].x = clampf(state->obstacles[i].x, minObstacleX, maxObstacleX);
            }

            // Collision check
            if (check_collision(state->playerX, state->playerY, state->playerRadius, 
                               state->obstacles[i].x, state->obstacles[i].y, state->obstacles[i].radius)) {
                
                if (state->obstacles[i].type == 0) {
                    state->score += 15;
                    state->health += 8;
                } else if (state->obstacles[i].type == 1) {
                    state->health -= 18;
                } else if (state->obstacles[i].type == 2) {
                    state->health -= 30;
                    state->score -= 4;
                    if (state->score < 0) state->score = 0;
                } else {
                    state->score += 25;
                    state->health += 3;
                }

                if (state->health > 100) state->health = 100;
                if (state->health <= 0) state->isGameOver = true;
                state->obstacles[i].active = false;
            }

            // Cleanup
            if (state->obstacles[i].y > (1.15f + state->obstacles[i].radius)) {
                state->obstacles[i].active = false;
            }
        }
    }
}
