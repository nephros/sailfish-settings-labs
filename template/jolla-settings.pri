INSTALLS += entry qml

entry.files = $$PWD/entries/$${TARGET}.json
entry.path = /usr/share/jolla-settings/entries

qml.files = qml
qml.path = /usr/share/sailfish-settings-labs/$${TARGET}
