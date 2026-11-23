/*
 * SPDX-License-Identifier: BSD-3-Clause
 * Copyright (c) 2026 Jolla Mobile Ltd
 * Copyright (c) 2026 Peter G. (nephros)
*/

import QtQuick 2.6
import Sailfish.Silica 1.0
//import Sailfish.Settings.Labs 1.0
import org.nemomobile.systemsettings 1.0

Page {
    id: root

    property ListModel lcSettings: ListModel{}
    property ListModel testingModel: ListModel{
        ListElement {
            section: 0
            name: "All"
            variable: "LC_ALL"
            value: ""
        }
        ListElement {
            section: 1
            name: "CType"
            variable: "LC_CTYPE"
            value: ""
        }
        ListElement {
            section: 2
            name: "Collation"
            variable: "LC_COLLATE"
            value: ""
        }
        ListElement {
            section: 3
            name: "Messages"
            variable: "LC_MESSAGES"
            value: ""
        }
        ListElement {
            section: 4
            name: "Monetary"
            variable: "LC_MONETARY"
            value: ""
        }
        ListElement {
            section: 5
            name: "Numeric"
            variable: "LC_NUMERIC"
            value: ""
        }
        ListElement {
            section: 6
            name: "Time"
            variable: "LC_TIME"
            value: ""
        }
    }

    // signal languageClicked(string language, string locale)

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: content.height

        Column {
            id: content

            width: page.width - Theme.horizontalPageMargin
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Theme.paddingMedium

            PageHeader {
                //% "Advanced Locale Settings"
                //: section header
                title: qsTrId("settings-sailfish_labs-locale-he-title")
            }

            Repeater {
                width: parent.width
                model: root.testingModel
                //model: root.lcSettings
                delegate: Column {
                    width: parent.width
                    //DetailItem {
                    ValueButton {
                        label: model.section + " " + model.name
                        value: model.value
                        //onClicked: changeLocaleSection(model.section)
                    }
                }
            }
        }
    }

    LanguageModel {
        id: languageModel

        Component.onCompleted: {
            var sections = getAdditionalLocaleSections()
            console.debug("Sections:" , JSON.stringify(sections, null, 2))
            sections.forEach(function(e) { root.lcSettings.append(e) })
        }
    }

    function changeLocaleSection(section) {
    }
}
