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

import QtQuick 2.4

Item {
    id: keyboardRect

    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    height: Qt.inputMethod.visible ? Qt.inputMethod.keyboardRectangle.height : 0

    states: [
        State {
            name: "hidden"
            when: keyboardRect.height == 0
        },
        State {
            name: "shown"
            when: keyboardRect.height == Qt.inputMethod.keyboardRectangle.height
        }
    ]

    function recursiveFindFocusedItem(parent) {
        if (parent.activeFocus) {
            return parent;
        }

        for (var i in parent.children) {
            var child = parent.children[i];
            if (child.activeFocus) {
                return child;
            }

            var item = recursiveFindFocusedItem(child);

            if (item != null) {
                return item;
            }
        }

        return null;
    }

    Connections {
        target: Qt.inputMethod

        onVisibleChanged: {
            if (!Qt.inputMethod.visible) {
                var focusedItem = recursiveFindFocusedItem(keyboardRect.parent);
                if (focusedItem != null) {
                    focusedItem.focus = false;
                }
            }
        }
    }
}
