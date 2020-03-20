// Pegasus Frontend
// Copyright (C) 2017-2019  Mátyás Mustoha
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.


#include "GamepadManagerQt.h"

#include "types/GamepadKeyId.h"


namespace {
GamepadButton translate_button(QGamepadManager::GamepadButton button)
{
#define GEN(from, to) case QGamepadManager::GamepadButton::Button##from: return GamepadButton::to
    switch (button) {
        GEN(Up, UP);
        GEN(Down, DOWN);
        GEN(Left, LEFT);
        GEN(Right, RIGHT);
        GEN(A, SOUTH);
        GEN(B, EAST);
        GEN(X, WEST);
        GEN(Y, NORTH);
        GEN(L1, L1);
        GEN(L2, L2);
        GEN(L3, L3);
        GEN(R1, R1);
        GEN(R2, R2);
        GEN(R3, R3);
        GEN(Select, SELECT);
        GEN(Start, START);
        GEN(Guide, GUIDE);
        default:
            return GamepadButton::INVALID;
    }
#undef GEN
}
GamepadAxis translate_axis(QGamepadManager::GamepadAxis axis)
{
#define GEN(from, to) case QGamepadManager::GamepadAxis::Axis##from: return GamepadAxis::to
    switch (axis) {
        GEN(LeftX, LEFTX);
        GEN(LeftY, LEFTY);
        GEN(RightX, RIGHTX);
        GEN(RightY, RIGHTY);
        default:
            return GamepadAxis::INVALID;
    }
#undef GEN
}
} // namespace


namespace model {

GamepadManagerQt::GamepadManagerQt(QObject* parent)
    : GamepadManagerBackend(parent)
{
    connect(QGamepadManager::instance(), &QGamepadManager::gamepadConnected,
            this, &GamepadManagerQt::fwd_connection);
    connect(QGamepadManager::instance(), &QGamepadManager::gamepadDisconnected,
            this, &GamepadManagerBackend::disconnected);
#if (QT_VERSION >= QT_VERSION_CHECK(5, 11, 0))
    connect(QGamepadManager::instance(), &QGamepadManager::gamepadNameChanged,
            this, &GamepadManagerBackend::nameChanged);
#endif

    connect(QGamepadManager::instance(), &QGamepadManager::gamepadButtonPressEvent,
            this, &GamepadManagerQt::fwd_button_press);
    connect(QGamepadManager::instance(), &QGamepadManager::gamepadButtonReleaseEvent,
            this, &GamepadManagerQt::fwd_button_release);
    connect(QGamepadManager::instance(), &QGamepadManager::gamepadAxisEvent,
            this, &GamepadManagerQt::fwd_axis_event);
    connect(QGamepadManager::instance(), &QGamepadManager::axisConfigured,
            this, &GamepadManagerQt::fwd_axis_cfg);
    connect(QGamepadManager::instance(), &QGamepadManager::buttonConfigured,
            this, &GamepadManagerQt::fwd_button_cfg);
    connect(QGamepadManager::instance(), &QGamepadManager::configurationCanceled,
            this, &GamepadManagerQt::configurationCanceled);

}

void GamepadManagerQt::start()
{
    for (const int device_id : QGamepadManager::instance()->connectedGamepads())
        fwd_connection(device_id);
}

void GamepadManagerQt::fwd_connection(int device_id)
{
    emit connected(device_id, QString());
}

void GamepadManagerQt::fwd_button_press(int device_id, QGamepadManager::GamepadButton button)
{
    emit buttonChanged(device_id, translate_button(button), true);
}

void GamepadManagerQt::fwd_button_release(int device_id, QGamepadManager::GamepadButton button)
{
    emit buttonChanged(device_id, translate_button(button), false);
}

void GamepadManagerQt::fwd_axis_event(int device_id, QGamepadManager::GamepadAxis axis, double value)
{
    emit axisChanged(device_id, translate_axis(axis), value);
}

void GamepadManagerQt::fwd_button_cfg(int device_id, QGamepadManager::GamepadButton button)
{
    emit buttonConfigured(device_id, translate_button(button));
}

void GamepadManagerQt::fwd_axis_cfg(int device_id, QGamepadManager::GamepadAxis axis)
{
    emit axisConfigured(device_id, translate_axis(axis));
}

} // namespace model
