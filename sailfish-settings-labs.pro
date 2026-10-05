TEMPLATE=subdirs

#SUBDIRS += template

include(template/jolla-settings.pri)

readme.files += README.md
readme.path = /usr/share/$${TARGET}
INSTALLS += readme

entries.files += entries
entries.path = /usr/share/jolla-settings
INSTALLS += entries
