TEMPLATE = aux

INSTALLS += entry qml

NAME=gestures

entry.files = $$PWD/entries/$${NAME}.json
entry.path = /usr/share/jolla-settings/entries

qml.files = qml/gestures.qml \
            qml/quickapptoggle.qml

qml.path = /usr/share/sailfish-settings-labs/$${NAME}
