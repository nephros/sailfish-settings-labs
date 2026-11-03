TEMPLATE = aux

TARGET = xdg-output

INSTALLS += entry qml

lupdate_only {
    SOURCES += \
        qml/main.qml
}

TRANS_TAG = settings-sailfish-labs
TS_FILE = $$OUT_PWD/$${TRANS_TAG}-${TARGET}.ts
EE_QM = $$OUT_PWD/$${TRANS_TAG}-$${TARGET}_eng_en.qm

entry.files = $$PWD/entries/labs-$${TARGET}.json
entry.path = /usr/share/jolla-settings/entries

qml.files = qml/main.qml
qml.path = /usr/share/sailfish-settings-labs/$${TARGET}

include(../translations.pri)

