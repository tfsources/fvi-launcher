// gameOS theme
// Copyright (C) 2018-2020 Seth Powell 
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

import QtQuick 2.3
import QtQuick.Layouts 1.11
import SortFilterProxyModel 0.2
import QtGraphicalEffects 1.0
import QtQml.Models 2.10
import "../Global"
import "../GridView"
import "../Lists"
import "../utils.js" as Utils

FocusScope {
id: root

    // Pull in our custom lists and define
    ListFavorites { id: listAllFavorites; max: 15 }
    ListAllGames { id: listAllGames; max: 15 }
    ListTopGames { id: listTopGames; max: 15 }
    ListLastPlayed { id: listAllLastPlayed; max: 10 }
    ListMostPlayed { id: listMostPlayed; max: 15 }
    ListPublisher { id: listPublisher; max: 15 }
    ListGenre { id: listGenre; max: 15 }

    property var featuredCollection: (listAllFavorites.collection.games.count !== 0) ? listAllFavorites : listTopGames
    property alias collection1: listAllLastPlayed
    property alias collection2: listMostPlayed
    property alias collection3: listGenre
    property alias collection4: listPublisher

    property string randoPub: Utils.returnRandom(Utils.uniqueValuesArray('publisher'))
    property string randoGenre: Utils.returnRandom(Utils.uniqueValuesArray('genreList'))[0].toLowerCase()

    function storeIndices(secondary) {
        storedHomePrimaryIndex = mainList.currentIndex;
        if (secondary)
            storedHomeSecondaryIndex = secondary;
    }

    Component.onDestruction: storeIndices();
    
    anchors.fill: parent

    Item {
    id: header

        width: parent.width
        height: vpx(70)
        z: 10
        Image {
        id: logo
		// not needed right now
        }

        Rectangle {
        id: settingsbutton

            width: height
            height: vpx(40)
            anchors { right: parent.right; rightMargin: globalMargin }
            color: focus ? theme.accent : "white"
            radius: height/2
            opacity: focus ? 1 : 0.2
            anchors.verticalCenter: parent.verticalCenter
            onFocusChanged: {
                sfxNav.play()
                if (focus)
                    mainList.currentIndex = -1;
                else
                    mainList.currentIndex = 0;
            }

            Keys.onDownPressed: mainList.focus = true;
            Keys.onPressed: {
                // Accept
                if (api.keys.isAccept(event) && !event.isAutoRepeat) {
                    event.accepted = true;
                    settingsScreen();            
                }
                // Back
                if (api.keys.isCancel(event) && !event.isAutoRepeat) {
                    event.accepted = true;
                    mainList.focus = true;
                }
            }
            // Mouse/touch functionality
            MouseArea {
                anchors.fill: parent
                onEntered: {}
                onExited: {}
                onClicked: settingsScreen();
            }
        }

        Image {
        id: settingsicon

            width: height
            height: vpx(24)
            anchors.centerIn: settingsbutton
            smooth: true
            asynchronous: true
            source: "../assets/images/settingsicon.svg"
            opacity: root.focus ? 0.8 : 0.5
        }
    }

    // Using an object model to build the list
    ObjectModel {
    id: mainModel

        ListView {
        id: featuredlist

            property bool selected: ListView.isCurrentItem
            focus: selected
            width: parent.width
            height: vpx(360)
            spacing: vpx(0)
            orientation: ListView.Horizontal
            clip: true
            preferredHighlightBegin: vpx(0)
            preferredHighlightEnd: parent.width
            //highlightRangeMode: ListView.StrictlyEnforceRange
            //highlightMoveDuration: 200
            highlightMoveVelocity: -1
            snapMode: ListView.SnapOneItem
            keyNavigationWraps: true
            currentIndex: (storedHomePrimaryIndex === 0) ? storedHomeSecondaryIndex : 0
            Component.onCompleted: positionViewAtIndex(currentIndex, ListView.Visible)
            
            model: featuredCollection.collection.games
            delegate: featuredDelegate

            Component {
            id: featuredDelegate

                Image {
                id: background

                    property bool selected: ListView.isCurrentItem && featuredlist.focus
                    width: featuredlist.width
                    height: featuredlist.height
                    source: Utils.fanArt(modelData);
                    sourceSize { width: featuredlist.width; height: featuredlist.height }
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    Rectangle {
                        
                        anchors.fill: parent
                        color: "black"
                        opacity: featuredlist.focus ? 0 : 0.5
                        Behavior on opacity { PropertyAnimation { duration: 150; easing.type: Easing.OutQuart; easing.amplitude: 2.0; easing.period: 1.5 } }
                    }

                    Image {
                    id: specialLogo

                        width: parent.height - vpx(20)
                        height: width
                        source: Utils.logo(modelData)
                        fillMode: Image.PreserveAspectFit
                        asynchronous: true
                        sourceSize { width: 256; height: 256 }
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        opacity: featuredlist.focus ? 1 : 0.5
                    }

                    // Mouse/touch functionality
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: settings.MouseHover == "Yes"
                        onEntered: { sfxNav.play(); mainList.currentIndex = 0; }
                        onClicked: {
                            if (selected)
                                gameDetails(modelData);  
                            else
                                mainList.currentIndex = 0;
                        }
                    }
                }
            }
            
            Row {
            id: blips

                anchors.horizontalCenter: parent.horizontalCenter
                anchors { bottom: parent.bottom; bottomMargin: vpx(20) }
                spacing: vpx(10)
                Repeater {
                    model: featuredlist.count
                    Rectangle {
                        width: vpx(10)
                        height: width
                        color: (featuredlist.currentIndex == index) && featuredlist.focus ? theme.accent : theme.text
                        radius: width/2
                        opacity: (featuredlist.currentIndex == index) ? 1 : 0.5
                    }
                }
            }

            // List specific input
            Keys.onUpPressed: settingsbutton.focus = true;
            Keys.onLeftPressed: { sfxNav.play(); decrementCurrentIndex() }
            Keys.onRightPressed: { sfxNav.play(); incrementCurrentIndex() }
            Keys.onPressed: {
                // Accept
                if (api.keys.isAccept(event) && !event.isAutoRepeat) {
                    event.accepted = true;
                    storedHomeSecondaryIndex = featuredlist.currentIndex;
                    if (!ftue)
                        gameDetails(featuredCollection.currentGame(currentIndex));            
                }
            }
        }
        
        // Collections list
        ListView {
        id: platformlist

            property bool selected: ListView.isCurrentItem
            property int myIndex: ObjectModel.index
            focus: selected
            width: root.width
            height: vpx(100)
            anchors {
                left: parent.left; leftMargin: globalMargin
                right: parent.right; rightMargin: globalMargin
            }
            spacing: vpx(10)
            orientation: ListView.Horizontal
            preferredHighlightBegin: vpx(0)
            preferredHighlightEnd: parent.width - vpx(60)
            highlightRangeMode: ListView.StrictlyEnforceRange
            snapMode: ListView.SnapOneItem
            highlightMoveDuration: 100
            keyNavigationWraps: true
            
            property int savedIndex: currentCollectionIndex
            onFocusChanged: {
                if (focus)
                    currentIndex = savedIndex;
                else {
                    savedIndex = currentIndex;
                    currentIndex = -1;
                }
            }

            Component.onCompleted: positionViewAtIndex(savedIndex, ListView.End)

            model: Utils.reorderCollection(api.collections);
            delegate: Rectangle {
                property bool selected: ListView.isCurrentItem && platformlist.focus
                width: vpx(150)
                height: vpx(100)
                color: selected ? theme.accent : theme.secondary
                scale: selected ? 1.1 : 1
                Behavior on scale { NumberAnimation { duration: 100 } }
                border.width: vpx(1)
                border.color: "#19FFFFFF"

                Image {
                id: collectionlogo

                    anchors.fill: parent
                    anchors.centerIn: parent
                    anchors.margins: vpx(15)
                    source: "../assets/images/logospng/" + Utils.processPlatformName(modelData.shortName) + ".png"
                    sourceSize { width: 128; height: 64 }
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    smooth: true
                    opacity: selected ? 1 : 0.2
                    scale: selected ? 1.1 : 1
                    Behavior on scale { NumberAnimation { duration: 100 } }
                }

                Text {
                id: platformname

                    text: modelData.name
                    anchors { fill: parent; margins: vpx(10) }
                    color: "white"
                    opacity: selected ? 1 : 0.2
                    Behavior on opacity { NumberAnimation { duration: 100 } }
                    font.pixelSize: vpx(18)
                    font.family: subtitleFont.name
                    font.bold: true
                    style: Text.Outline; styleColor: theme.main
                    visible: collectionlogo.source == ""
                    anchors.centerIn: parent
                    elide: Text.ElideRight
                    wrapMode: Text.WordWrap
                    lineHeight: 0.8
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                // Mouse/touch functionality
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: settings.MouseHover == "Yes"
                    onEntered: { sfxNav.play(); mainList.currentIndex = platformlist.ObjectModel.index; platformlist.savedIndex = index; platformlist.currentIndex = index; }
                    onExited: {}
                    onClicked: {
                        if (selected)
                        {
                            currentCollectionIndex = index;
                            softwareScreen();
                        } else {
                            mainList.currentIndex = platformlist.ObjectModel.index;
                            platformlist.currentIndex = index;
                        }
                        
                    }
                }
            }

            // List specific input
            Keys.onLeftPressed: { sfxNav.play(); decrementCurrentIndex() }
            Keys.onRightPressed: { sfxNav.play(); incrementCurrentIndex() }
            Keys.onPressed: {
                // Accept
                if (api.keys.isAccept(event) && !event.isAutoRepeat) {
                    event.accepted = true;
                    currentCollectionIndex = platformlist.currentIndex;
                    softwareScreen();            
                }
            }

        }

        HorizontalCollection {
        id: list1
            
            property bool selected: ListView.isCurrentItem
            focus: selected
            width: root.width - globalMargin*2
            height: vpx(240)
            itemWidth: vpx(310)
            itemHeight: vpx(200)
            x: globalMargin - vpx(8)

            title: "Continue playing"
            ListLastPlayed { id: lastPlayedCollection; max:15 }
            search: lastPlayedCollection
            savedIndex: (storedHomePrimaryIndex === list1.ObjectModel.index) ? storedHomeSecondaryIndex : 0

            onActivateSelected: storedHomeSecondaryIndex = currentIndex;
            onActivate: { if (!selected) { mainList.currentIndex = list1.ObjectModel.index; } }
            onListHighlighted: { sfxNav.play(); mainList.currentIndex = list1.ObjectModel.index; }
        }

        HorizontalCollection {
        id: list2
            
            property bool selected: ListView.isCurrentItem
            focus: selected
            width: root.width - globalMargin*2
            height: vpx(270)
            x: globalMargin - vpx(8)

            title: "Most played games"
            ListMostPlayed { id: mostPlayedCollection; max: 15 }
            search: mostPlayedCollection
            savedIndex: (storedHomePrimaryIndex === list2.ObjectModel.index) ? storedHomeSecondaryIndex : 0
            
            onActivateSelected: storedHomeSecondaryIndex = currentIndex;
            onActivate: { if (!selected) { mainList.currentIndex = list2.ObjectModel.index; } }
            onListHighlighted: { sfxNav.play(); mainList.currentIndex = list2.ObjectModel.index; }
        }

        HorizontalCollection {
        id: list3
            
            property bool selected: ListView.isCurrentItem
            focus: selected
            width: root.width - globalMargin*2
            height: vpx(240)
            itemWidth: vpx(310)
            itemHeight: vpx(200)
            x: globalMargin - vpx(5)

            
            ListPublisher { id: publisherCollection; max: 15; publisher: randoPub }
            title: "Top games by " + randoPub
            search: publisherCollection
            
            onActivate: { if (!selected) { mainList.currentIndex = list3.ObjectModel.index; } }
            onListHighlighted: { sfxNav.play(); mainList.currentIndex = list3.ObjectModel.index; }
        }

        HorizontalCollection {
        id: list4
            
            property bool selected: ListView.isCurrentItem
            focus: selected
            width: root.width - globalMargin*2
            height: vpx(300)
            x: globalMargin - vpx(8)

            ListGenre { id: genreCollection; max: 15; genre: randoGenre }
            title: "Top " + randoGenre + " games"
            search: genreCollection
            
            onActivate: { if (!selected) { mainList.currentIndex = list4.ObjectModel.index; } }
            onListHighlighted: { sfxNav.play(); mainList.currentIndex = list4.ObjectModel.index; }

            Keys.onDownPressed: {
                mainList.currentIndex = 0;
            }
        }

    }

    ListView {
    id: mainList

        anchors.fill: parent
        model: mainModel
        spacing: globalMargin
        focus: true
        highlightMoveDuration: 200
        highlightRangeMode: ListView.ApplyRange 
        preferredHighlightBegin: header.height
        preferredHighlightEnd: parent.height - (helpMargin * 2)
        snapMode: ListView.SnapOneItem
        keyNavigationWraps: true
        currentIndex: storedHomePrimaryIndex
        
        cacheBuffer: 1000
        footer: Item { height: helpMargin }

        Keys.onUpPressed: { sfxNav.play(); decrementCurrentIndex() }
        Keys.onDownPressed: { sfxNav.play(); incrementCurrentIndex() }
    }

    // Global input handling for the screen
    Keys.onPressed: {
        // Settings
        if (api.keys.isFilters(event) && !event.isAutoRepeat) {
            event.accepted = true;
            settingsScreen();
        }
    }

    // Helpbar buttons
    ListModel {
        id: gridviewHelpModel

        ListElement {
            name: "Settings"
            button: "filters"
        }
        ListElement {
            name: "Select"
            button: "accept"
        }
    }

    onFocusChanged: { 
        if (focus)
            currentHelpbarModel = gridviewHelpModel;
    }

}