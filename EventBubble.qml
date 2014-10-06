/*
 * Copyright (C) 2013-2014 Canonical Ltd
 *
 * This file is part of Ubuntu Calendar App
 *
 * Ubuntu Calendar App is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * Ubuntu Calendar App is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.3
import Ubuntu.Components 1.1


Item{
    id: infoBubble

    property var event;
    property var model;

    property int type: narrowType
    property int wideType: 1;
    property int narrowType: 2;

    property int depthInRow: 0;
    property int sizeOfRow:0

    property Flickable flickable;

    readonly property int minimumHeight: timeLabel.height + /*top-bottom margin*/ units.gu(2)

    signal clicked(var event);

    UbuntuShape{
        id: bg
        anchors.fill: parent
    }

    function resize() {
        var offset = parent.width/sizeOfRow;
        x = (depthInRow) * offset;
        width = parent.width - x;
    }

    Connections{
        target: parent
        onWidthChanged:{
            resize();
        }
    }

    onEventChanged: {
        resize();
        setDetails();
    }

    //on weekview flickable changes, so we need to setup connection on flickble change
    onFlickableChanged: {
        if( flickable && height > flickable.height ) {
            flickable.onContentYChanged.connect(layoutBubbleDetails);
        }
    }

    //on dayview, flickable never changed so when height changes we setup connection
    onHeightChanged: {
        if( flickable && height > flickable.height ) {
            flickable.onContentYChanged.connect(layoutBubbleDetails);
        }
    }

    Component.onCompleted: {
        setDetails();
    }

    function setDetails() {
        if(event === null || event === undefined) {
            return;
        }

        var startTime = event.startDateTime.toLocaleTimeString(Qt.locale(), Locale.ShortFormat)
        var endTime = event.endDateTime.toLocaleTimeString(Qt.locale(), Locale.ShortFormat)

        // TRANSLATORS: the first argument (%1) refers to a start time for an event,
        // while the second one (%2) refers to the end time
        var timeString = i18n.tr("%1 - %2").arg(startTime).arg(endTime)

        timeLabel.text = ""
        titleLabel.text = ""
        descriptionLabel.text = ""
        if (type === wideType) {
            //height is less then set only event title
            if( height > minimumHeight ) {
                //on wide type show all details
                timeLabel.text = timeString
                if (event.displayLabel)
                    titleLabel.text = event.displayLabel;
                if (event.description)
                {
                    descriptionLabel.text = event.description
                    //If content is too much don't display.
                    if (height < descriptionLabel.height + descriptionLabel.y) {
                        descriptionLabel.text = ""
                    }
                }

            } else {
                if (event.displayLabel)
                    timeLabel.text = event.displayLabel;
            }
        }
        if (model) {
            var collection = model.collection( event.collectionId );
            bg.color = collection.color
        }

        layoutBubbleDetails();
    }

    function layoutBubbleDetails() {
        if( !flickable || flickable === undefined ) {
            return;
        }

        if( infoBubble.y < flickable.contentY && infoBubble.height > flickable.height) {
            var y = (flickable.contentY - infoBubble.y) * 1.2;
            if( ( y + detailsItems.height + units.gu(2)) > infoBubble.height) {
                y = infoBubble.height - detailsItems.height - units.gu(2);
            }
            detailsItems.y = y;
        }
    }

    Connections{
        target: detailsItems
        onHeightChanged: {
            layoutBubbleDetails();
        }
    }

    Item {
        id: detailsItems

        width: parent.width
        height: detailsColumn.height

        Column {
            id: detailsColumn

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: units.gu(1)
            }

            Label {
                id: timeLabel
                objectName: "timeLabel"
                color: "White"
                fontSize:"small"
                font.bold: true
                width: parent.width
            }

            Label {
                id: titleLabel
                objectName: "titleLabel"
                color: "White"
                fontSize: "small"
                width: parent.width
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            }

            Label {
                id: descriptionLabel
                color: "White"
                fontSize: "x-small"
                width: parent.width
                visible: type == wideType
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            }
        }
    }

    MouseArea{
        anchors.fill: parent
        onClicked: {
            infoBubble.clicked(event);
        }
    }
}
