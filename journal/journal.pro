TEMPLATE = aux

INSTALLS += entry qml components

NAME=journal

entry.files = $$PWD/entries/labs-$${NAME}.json
entry.path = /usr/share/jolla-settings/entries

qml.files = qml/journal.qml qml/config.js
qml.path = /usr/share/sailfish-settings-labs/$${NAME}

components.files = $$files(qml/components/*.qml)
components.path = /usr/share/sailfish-settings-labs/$${NAME}/components
