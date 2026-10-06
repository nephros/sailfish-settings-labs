TEMPLATE = aux

INSTALLS += entry qml

NAME=quick-app-toggle

entry.files = $$PWD/entries/$${NAME}.json
entry.path = /usr/share/jolla-settings/entries

qml.files = $$files(qml/*.qml)
qml.path = /usr/share/sailfish-settings-labs/$${NAME}
