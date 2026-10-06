/*
 * Copyright (c) 2026 Peter G. (nephros)
 * SPDX-License-Identifier: Apache-2.0
 * SPDX-License-Identifier: BSD-3-Clause
 */


import QtQuick 2.1
import Sailfish.Silica 1.0
import Nemo.DBus 2.0
import Nemo.Configuration 1.0

Page { id: root

    ConfigurationValue {
        id: quickAppToggleConfig
        key: "/desktop/sailfish/experimental/quickAppToggleGesture"
        defaultValue: false
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        PullDownMenu {
            MenuItem {
                //% "Reset to default"
                //: menu entry
                text: qsTrId("settings-sailfish_labs-quick-app-toggle-menu-reset")
                onDelayedClick: quickAppToggleConfig.value = quickAppToggleConfig.defaultValue()
            }
        }
        Column { id: column
            width: page.width - Theme.horizontalPageMargin
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Theme.paddingMedium

            PageHeader {
                //% "Quick App Switching"
                //: section header
                title: qsTrId("settings-sailfish_labs-quick-app-toggle-page-adv-section-quicksw")
             }

            Label {
                width: parent.width
                wrapMode: Text.Wrap
                color: Theme.secondaryHighlightColor
                textFormat: Text.StyledText
                font.pixelSize: Theme.fontSizeSmall
                //% "Similar to pressing Alt + Tab on a desktop to switch to the previous app window. However, Quick App Switching can only jump to the previous app."
                text: qsTrId("settings-sailfish_labs-quick-app-toggle-page-adv-label-1")
            }
            TextSwitch{ id: quickToggleSwitch
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                checked: quickAppToggleConfig.value
                automaticCheck: true
                //% "Quick App Switching"
                //: quick app switch text
                text: qsTrId("settings-sailfish_labs-quick-app-toggle-quicksw-name")
                //% "Once enabled you can switch from the foregound app to the previous one by doing a long peek gesture."
                //: quick app switch description
                description: qsTrId("settings-sailfish_labs-quick-app-toggle-quicksw-desc")
                onClicked: quickAppToggleConfig.value = !quickAppToggleConfig.value
            }
        }
    }
}

// vim: ft=javascript expandtab ts=4 sw=4 st=4 syntax=qml
