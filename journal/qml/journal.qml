/*
 * Copyright (c) 2026 Peter G. (nephros)
 * SPDX-License-Identifier: Apache-2.0
 * SPDX-License-Identifier: BSD-3-Clause
 */


import QtQuick 2.1
import Sailfish.Silica 1.0
//import Sailfish.Settings.Labs 1.0
import org.nemomobile.systemsettings 1.0 // developer mode setting
import Nemo.FileManager 1.0
import Sailfish.Share 1.0 // for file writing
import Nemo.DBus 2.0

Page {
    id: root

    readonly property string configRoot: "/etc/systemd"
    //readonly property string configRoot: "/run/systemd"
    readonly property string configDir: "journald.conf.d"
    /* man 5 journald.conf
       It is recommended to use the range 10-40 for drop-ins in /usr/ and the
       range 60-90 for drop-ins in /etc/ and /run/, to make sure that local and
       transient drop-ins take priority over drop-ins shipped by the OS vendor.
    */
    readonly property string configPrefix: "60"
    readonly property string configFile:    configRoot + "/" + configDir + "/" + configPrefix + "-jolla-settings-labs-journal.conf"
    readonly property string configFileDev: configRoot + "/" + configDir + "/" + configPrefix + "-jolla-settings-labs-journal-developer.conf"

    property bool needsServiceRestart: false

    signal configRead(string content)

    Component.onCompleted: {
        if (!FileEngine.exists(configFile)) {
            loadCurrentSettings()
        }
    }

    /* FIXME: we don't really parse the values here */
    function loadCurrentSettings() {
        root.configRead.connect(function(content) {
            content.split("\n").forEach(function(line) {
                const variable = line.split("=")[0]
                const value = line.split("=")[0]
                if (/^MaxLevelStore/.test(variable)) { levelBox.currentValue = value }
                if (/^ReadKMsg/.test(variable)) { kmsgSwitch.checked = (value == "true") }
                if (/^Storage/.test(variable)) { persistSwitch.checked = ( value == "persistent" ) }
//                if (/^SystemMaxUse/.test(variable)) {}
//                if (/^RuntimeMaxUse/.test(variable)) {}
            })
        })
    }

    function applyAndRestartJournal() {
        prepareContent(true)
    }

    function applyAndReboot() {
        prepareContent(false)
    }

    function restartJournalD() {
        // no point in checking for success, the method returns a Job object.
        // We *could* monitor the job, but what's the point...
        journald.call("Restart", [ "replace" ])
    }

    function resetToDefault() {
        FileEngine.deleteFiles( [ configFile ], false)
        restartJournalD()
    }

    function prepareContent(restart) {
        var fileContent = [ ]

        if ( (levelBox.currentIndex != -1) && (levelBox.currentIndex != valueConfig.levelDefault) )
            fileContent.push("MaxLevelStore=%1".arg(valueConfig.levels[levelBox.currentIndex]))

        if (!kmsgSwitch.checked)
            fileContent.push("ReadKMsg=no")

        if (persistSwitch.checked) {
            fileContent.push("Storage=persistent")
            if ( pSizeBox.currentIndex != -1)
                fileContent.push("SystemMaxUse=%1M".arg(pSizeBox.configValue))
        } else {
            if ( vSizeBox.currentIndex != -1)
                fileContent.push("RuntimeMaxUse=%1M".arg(vSizeBox.configValue))
        }

        if (fileContent.length > 0) {
            const payload = "### This file has been created by Jolla Settings Labs.\n### Please do not edit!\n#\n[Journal]\n"
                            + fileContent.join("\n")
            console.debug("Created file payload:", payload)
            if (!FileEngine.exists(configRoot+ "/" + configDir)) {
                FileEngine.mkdir(configRoot, configDir)
                console.debug("Created destination directory.")
                if (FileEngine.exists(configRoot+ "/" + configDir)) {
                    console.debug("Deleting old file.")
                    FileEngine.fileDeleted.connect(function() { writeConfigFile(configFile, payload) } )
                    FileEngine.deleteFiles( [ configFile ], false)
                } else {
                     writeConfigFile(configFile, payload, restart)
                }
            }
        }
    }

    function readFile(path) {
        const qurl = Qt.resolvedUrl(path)
        var r = new XMLHttpRequest()
        r.open("GET", qurl)
        r.onreadystatechange = function(event) {
            if (r.readyState == XMLHttpRequest.DONE) {
                console.debug("Read config file: ", r.responseText)
                root.configRead(r.responseText)
            }
        }
        r.send()
    }


    function writeConfigFile(path, payload, restart) {
        console.debug("Writing config file:", path)
        const tmpname = ".settings-journald-" + Qt.md5(payload + Date.now());
        var tmpfile = writer.writeContentToFile ( { "name": tmpname, "type": "text/plain", "data": payload } );
        FileEngine.rename(tmpfile, path, false);
        //FileEngine.copyFiles( [ tmpfile ] );
        //FileEngine.pasteFiles(path, false);
        writer.removeFilesAndRmdir( [ tmpfile ] );
        if (restart) restartJournalD();

        /*
        const qurl = Qt.resolvedUrl(path)
        var r = new XMLHttpRequest()
        r.open("PUT", qurl)
        r.onreadystatechange = function(event) {
            if (r.readyState == XMLHttpRequest.DONE) {
                if (restart) restartJournalD()
            }
        }
        r.send(payload)
        */
    }

    QtObject {
        id: valueConfig
        readonly property var levels: [ "emerg", "alert", "crit", "err", "warning", "notice", "info", "debug" ]
        readonly property int levelDefault: 7 // "debug"
        readonly property var smallSizes: [ 1, 3, 5, 15, 50, 100 ]
        readonly property int smallSizeDefault: 0 // index!
        readonly property var largeSizes: [ 5, 10, 50, 120, 250, 500, 4000 ]
        readonly property int largeSizeDefault: 2 // index!, "50"

        readonly property int sendToNetPort: 4444
    }

    ContextMenu {
        id: levelMenu

        MenuItem {
            //% "Emergency"
            //: log level menu entry
            text: qsTrId("settings-sailfish_labs-journal-menu-level-emerg")
            //% "System is unusable"
            property string description: qsTrId("settings-sailfish_labs-journal-menu-level-emerg-desc")
        }
        MenuItem {
            //% "Alert"
            //: log level menu entry
            text: qsTrId("settings-sailfish_labs-journal-menu-level-alert")
            //% "Action must be taken immediately"
            property string description: qsTrId("settings-sailfish_labs-journal-menu-level-alert-desc")
        }
        MenuItem {
            //% "Critical"
            //: log level menu entry
            text: qsTrId("settings-sailfish_labs-journal-menu-level-crit")
            //% "Critical conditions"
            property string description: qsTrId("settings-sailfish_labs-journal-menu-level-crit-desc")
        }
        MenuItem {
            //% "Error"
            //: log level menu entry
            text: qsTrId("settings-sailfish_labs-journal-menu-level-err")
            //% "Error conditions"
            property string description: qsTrId("settings-sailfish_labs-journal-menu-level-err-desc")
        }
        MenuItem {
            //% "Warning"
            //: log level menu entry
            text: qsTrId("settings-sailfish_labs-journal-menu-level-warn")
            //% "Warning conditions"
            property string description: qsTrId("settings-sailfish_labs-journal-menu-level-warn-desc")
        }
        MenuItem {
            //% "Notice"
            //: log level menu entry
            text: qsTrId("settings-sailfish_labs-journal-menu-level-notice")
            //% "Normal but significant conditions"
            property string description: qsTrId("settings-sailfish_labs-journal-menu-level-notice-desc")
        }
        MenuItem {
            //% "Informational"
            //: log level menu entry
            text: qsTrId("settings-sailfish_labs-journal-menu-level-info")
            //% "Informational messages"
            property string description: qsTrId("settings-sailfish_labs-journal-menu-level-info-desc")
        }
        MenuItem {
            //% "Debug"
            //: log level menu entry
            text: qsTrId("settings-sailfish_labs-journal-menu-level-debug")
            //% "Debug-level messages"
            property string description: qsTrId("settings-sailfish_labs-journal-menu-level-debug-desc")
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        PullDownMenu {
            MenuItem {
                //% "Reset to default"
                //: menu entry
                text: qsTrId("settings-sailfish_labs-journal-menu-reset")
                onDelayedClick: Remorse.popupAction(
                    root,
                    //% "Resetting all to default"
                    //: remorse popup message
                    qsTrId("settings-sailfish_labs-journal-menu-reset-remorse"),
                    function() { root.resetToDefault() }
                )
            }
            MenuItem {
                //% "Apply and restart Log"
                //: menu entry
                text: qsTrId("settings-sailfish_labs-journal-menu-apply-restart")
                onDelayedClick: Remorse.popupAction(
                    root,
                    //% "Applying"
                    //: remorse popup message
                    //~ Apply and restart daemon
                    qsTrId("settings-sailfish_labs-journal-menu-apply-remorse"),
                    function() { root.applyAndRestartJournal() }
                )
            }
            MenuItem {
                //% "Apply and reboot Device"
                //: menu entry
                text: qsTrId("settings-sailfish_labs-journal-menu-apply-reboot")
                onDelayedClick: Remorse.popupAction(
                    root,
                    //% "Applying"
                    //: remorse popup message
                    //~ Apply and reboot
                    qsTrId("settings-sailfish_labs-journal-menu-apply-remorse"),
                    function() { applyAndRebootAnimation }
                )
            }
        }
        Column {
            id: column

            width: page.width - Theme.horizontalPageMargin
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Theme.paddingMedium

            PageHeader {
                //% "Logging"
                //: section header
                title: qsTrId("settings-sailfish_labs-journal-page-adv-section-quicksw")
            }

            Label {
                width: parent.width
                wrapMode: Text.Wrap
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeSmall
                //% "Use the controls below to change certain aspects of the system logging behavior"
                text: qsTrId("settings-sailfish_labs-journal-desc-label")
            }

            ComboBox {
                id: levelBox

                //% "Log Level"
                label: qsTrId("settings-sailfish_labs-journal-box-level-label")
                //% "The maxium severity of messages to show in the log"
                description: qsTrId("settings-sailfish_labs-journal-box-level-desc")
                //             + ( currentItem.description ? ": " + currentItem.description : "" )
                menu: levelMenu
                currentIndex: valueConfig.levels[valueConfig.levelDefault]
            }

            ComboBox {
                id: vSizeBox

                property int configValue: -1
                enabled: !persistSwitch.checked
                //% "Maximum size"
                label: qsTrId("settings-sailfish_labs-journal-box-size-v-label")
                //% "Maximum log size when “%1” is not enabled"
                //: %1 is the content of settings-sailfish_labs-journal-sw-persist, e.g. 'Keep logs on disk'
                description: qsTrId("settings-sailfish_labs-journal-sw-box-size-v-desc").arg(qsTrId("settings-sailfish_labs-journal-sw-persist"))
                onValueChanged: {
                    configValue = valueConfig.smallSizes[currentIndex]
                }
                menu: ContextMenu {
                    Repeater {
                        model: valueConfig.smallSizes
                        delegate: MenuItem {
                            //% "%Ln Megabyte(s)"
                            text: qsTrId("settings-sailfish_labs-journal-menu-ssize-mb", modelData)
                        }
                    }
                }

            }

            TextSwitch {
                id: kmsgSwitch

                checked: true
                //% "Include Kernel messages"
                text: qsTrId("settings-sailfish_labs-journal-sw-kmsg")
                //% "If turned off, messages from the Kernel will not be captured in the logs"
                description: qsTrId("settings-sailfish_labs-journal-sw-kmsg-desc")
            }

            TextSwitch {
                id: persistSwitch

                checked: false
                //% "Keep logs on Disk"
                text: qsTrId("settings-sailfish_labs-journal-sw-persist")
                //% "If enabled, log messages will be stored on disk and be available after a reboot"
                description: qsTrId("settings-sailfish_labs-journal-sw-persist-desc") + " " +
                      //% "The logging service needs to be restarted after changing this"
                      qsTrId("settings-sailfish_labs-journal-need-restart-desc")
            }

            ComboBox {
                id: pSizeBox

                property int configValue: -1
                enabled: persistSwitch.checked
                //% "Maximum size on Disk"
                label: qsTrId("settings-sailfish_labs-journal-box-size-p-label")
                //% "Maximum log size when “%1” is enabled"
                //: %1 is the content of settings-sailfish_labs-journal-sw-persist, e.g. 'Keep logs on disk'
                description: qsTrId("settings-sailfish_labs-journal-sw-box-size-p-desc").arg(qsTrId("settings-sailfish_labs-journal-sw-persist"))
                onValueChanged: {
                    configValue = valueConfig.largeSizes[currentIndex]
                }
                menu: ContextMenu {
                    Repeater {
                        model: valueConfig.largeSizes
                        delegate: MenuItem {
                            //% "%1 Megabytes"
                            text: qsTrId("settings-sailfish_labs-journal-menu-lsize-mb").arg(modelData)
                        }
                    }
                }
            }

            Loader {
                id: developerExtras

                active: developerModeSettings.developerModeEnabled
                source: Qt.resolvedUrl("components/DeveloperModeExtras.qml")
                Connections {
                    target: developerExtras.item
                    onLogToNetEnabled: { // TODO
                        if (enabled) {
                            const payload = "### This file has been created by Jolla Settings Labs.\n### Please do not edit!\n#\n[Journal]\n"
                                          + "ForwardToSocket=%1\n".arg(developerModeSettings.usbIpAddress + ":" + valueConfig.sendToNetPort)
                            root.writeConfigFile(configFileDev, payload, true)
                        } else {
                            FileEngine.deleteFiles( [ configFileDev ], false)
                            root.restartJournalD()
                        }
                    }
                }
            }
        }
    }

    SequentialAnimation {
        id: applyAndRebootAnimation

        FadeAnimation {
            duration: 600
            target: fadeOutRectangle
            to: 1.0
        }
        ScriptAction {
            script: root.applyAllAndReboot()
        }
    }
    Rectangle {
        id: fadeOutRectangle

        parent: __silica_applicationwindow_instance
        anchors.fill: parent
        color: "black"
        opacity: 0.0
    }

    DBusInterface {
        id: journald
        bus: DBus.SystemBus
        service: "org.freedesktop.systemd1"
        path: "/org/freedesktop/systemd1/unit/systemd_2djournald_2eservice"
        iface: "org.freedesktop.systemd1.Service"
    }

    ShareAction {
        id: writer
    }

    DeveloperModeSettings {
        id: developerModeSettings
    }
}

// vim: ft=javascript expandtab ts=4 sw=4 st=4 syntax=qml
