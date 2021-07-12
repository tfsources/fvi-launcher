// Pegasus Frontend
// Copyright (C) 2017-2018  Mátyás Mustoha
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


import "mainmenu"
import "qrc:/qmlutils" as PegasusUtils
import QtQuick 2.8


FocusScope {
    id: root

    width: vpx(350)
    height: parent.height
    visible: x < parent.width && 0 < x + width
    enabled: focus

    signal close
    signal showHelpScreen

    signal requestShutdown
    signal requestReboot
    signal requestQuit

    Keys.onPressed: {
        if (event.isAutoRepeat)
            return;

        if (api.keys.isCancel(event) || api.keys.isMenu(event)) {
            event.accepted = true;
            root.close();
        }
    }


    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        onClicked: root.close()
    }

    Rectangle {
        color: "#333"
        anchors.fill: parent
    }

    Column {
        width: parent.width
        anchors.bottom: parent.bottom
        anchors.bottomMargin: vpx(30)

        PrimaryMenuItem {
            id: mbHelp
            text: qsTr("About") + api.tr
            onActivated: {
                focus = true;
                root.showHelpScreen();
            }
            selected: focus

            KeyNavigation.down: scopeQuit
        }
        RollableMenuItem {
            id: scopeQuit
            name: qsTr("Quit") + api.tr

            enabled: callable
            visible: callable
            readonly property bool callable: mbQuitShutdown.callable
                || mbQuitReboot.callable
                || mbQuitExit.callable

            Component.onCompleted: {
                const first_callable = [mbQuitShutdown, mbQuitReboot, mbQuitExit].find(e => e.callable);
                if (first_callable) {
                    first_callable.focus = true;
                    scopeQuit.focus = true;
                } else {
                    mbHelp.focus = true;
                }
            }
        }
    }

    PegasusUtils.HorizontalSwipeArea {
        anchors.fill: parent
        onSwipeRight: close()
    }
}
