/*
 * Copyright (c) 2026 Peter G. (nephros)
 * SPDX-License-Identifier: Apache-2.0
 * SPDX-License-Identifier: BSD-3-Clause
 */


import QtQuick 2.1
import Sailfish.Silica 1.0
import Sailfish.Settings.Labs 1.0
import Nemo.Configuration 1.0

Page {
    id: root

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column

            width: page.width - Theme.horizontalPageMargin
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Theme.paddingMedium

            PageHeader {
                //% "Compositor Output"
                //: page header
                title: qsTrId("settings-sailfish_labs-xdg-output-page-he-title")
            }

            Label {
                width: parent.width
                wrapMode: Text.Wrap
                color: Theme.secondaryHighlightColor
                textFormat: Text.StyledText
                font.pixelSize: Theme.fontSizeSmall
                //% "Applications which use modern Wayland interfaces will be enabled to rotate their output windows according to the device orientation. This is mainly useful for things like ported apps using SDL or similar frameworks."
                text: qsTrId("settings-sailfish_labs-xdg-output-rotation-label")
            }

            TextSwitch {
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                checked: xdgWindowRotation.value
                automaticCheck: true
                //% "Rotation follows device orientation"
                text: qsTrId("settings-sailfish_labs-xdg-output-rotation-sw-text")
                // description: qsTrId("settings-sailfish_labs-xdg-output-rotation-sw-desc")
                onClicked: xdgWindowRotation.value = !xdgWindowRotation.value
            }
        }
    }

    ConfigurationValue {
        id: xdgWindowRotation

        key: "/desktop/lipstick-jolla-home/xdg_window_rotation"
        defaultValue: false
    }
}

// vim: ft=javascript expandtab ts=4 sw=4 st=4 syntax=qml
