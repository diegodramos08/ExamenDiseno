#ifndef __KEYPAD_H__
#define __KEYPAD_H__

#include <SDL.h>

#define KEY_LEFT_MASK   1u
#define KEY_RIGHT_MASK  2u
#define KEY_DOWN_MASK   4u
#define KEY_UP_MASK     8u
#define KEY_Q_MASK      16u
#define KEY_P_MASK      32u
#define KEY_B_MASK      64u
#define KEY_SPACE_MASK  128u 

enum class KeyState { Pressed, Released };

template<typename TKeypad>
void updateKeypadState(TKeypad& keypad, unsigned key, KeyState state)
{
    if (state == KeyState::Pressed)
    {
        if (key == SDLK_LEFT) keypad |= KEY_LEFT_MASK;
        if (key == SDLK_RIGHT) keypad |= KEY_RIGHT_MASK;
        if (key == SDLK_DOWN) keypad |= KEY_DOWN_MASK;
        if (key == SDLK_UP) keypad |= KEY_UP_MASK;
        if (key == SDLK_p) keypad |= KEY_P_MASK;
        if (key == SDLK_q) keypad |= KEY_Q_MASK;
        if (key == SDLK_b) keypad |= KEY_B_MASK;
        if (key == SDLK_SPACE) keypad |= KEY_SPACE_MASK;
    }
    else
    {
        if (key == SDLK_LEFT) keypad &= ~KEY_LEFT_MASK;
        if (key == SDLK_RIGHT) keypad &= ~KEY_RIGHT_MASK;
        if (key == SDLK_DOWN) keypad &= ~KEY_DOWN_MASK;
        if (key == SDLK_UP) keypad &= ~KEY_UP_MASK;
        if (key == SDLK_p) keypad &= ~KEY_P_MASK;
        if (key == SDLK_q) keypad &= ~KEY_Q_MASK;
        if (key == SDLK_b) keypad &= ~KEY_B_MASK;
        if (key == SDLK_SPACE) keypad &= ~KEY_SPACE_MASK;
    }
}

#endif
