HEADERS += \
    $$PWD/PowerCommands.h \

win32 {
    SOURCES += $$PWD/PowerCommands_win.cpp
}
else:unix {
    macx: SOURCES += $$PWD/PowerCommands_mac.cpp
    else: SOURCES += $$PWD/PowerCommands_linux.cpp
}
else {
    SOURCES += $$PWD/PowerCommands_unimpl.cpp
}
