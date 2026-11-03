TEMPLATE = aux

TARGET = xdg-output

INSTALLS += entry qml

entry.files = $$PWD/entries/labs-$${TARGET}.json
entry.path = /usr/share/jolla-settings/entries

qml.files = qml/main.qml
qml.path = /usr/share/sailfish-settings-labs/$${TARGET}
