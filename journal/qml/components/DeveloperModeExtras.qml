/*
 * Copyright (c) 2026 Peter G. (nephros)
 * SPDX-License-Identifier: Apache-2.0
 * SPDX-License-Identifier: BSD-3-Clause
 */


import QtQuick 2.1
import Sailfish.Silica 1.0
//import Sailfish.Settings.Labs 1.0
import com.jolla.settings.system 1.0     // NetworkAddressField


Column {
    id: root

    signal logToNetEnabled(bool enabled)

    width: page.width - Theme.horizontalPageMargin
    anchors.horizontalCenter: parent.horizontalCenter
    spacing: Theme.paddingMedium

    SectionHeader {
        //% "%1 Extras"
        //: "%1 is the name of the \"Developer Tools"\ settings name
        text: qsTrId("settings-sailfish_labs-journal-he-developers").arg(qsTrId("settings_developermode-he-developer_tools"))
    }
    TextSwitch {
        id: logToNet

        checked: false
        automaticCheck: false
        //% "Send logs over Network"
        text: qsTrId("settings-sailfish_labs-journal-sw-logtonet")
        //% "If enabled, the journal daemon will forward messages over the network."
        description: qsTrId("settings-sailfish_labs-journal-sw-logtonet-desc") + " " +
            //% "This will use the address configured the %1 for USB Networking."
            //: "%1 is the name of the \"Developer Tools"\ settings name
            qsTrId("settings-sailfish_labs-journal-sw-logtonet-desc2")
            .arg(qsTrId("settings_developermode-he-developer_tools")) + "\n" +
            //% "The logging service needs to be restarted after changing this"
            qsTrId("settings-sailfish_labs-journal-need-restart-desc")
        onClicked: {
            checked = !checked
            root.logToNetEnabled(checked)
        }
    }
    NetworkAddressField {
        icon: 'image://theme/icon-m-usb'
        //% "USB IP address"
        caption: qsTrId("settings_developermode-la-usb_ip_address")
        text: developerModeSettings.usbIpAddress + ":" + valueConfig.sendToNetPort
        readOnly: true
    }
}

// vim: ft=javascript expandtab ts=4 sw=4 st=4 syntax=qml
