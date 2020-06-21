TARGET = fvi-launcher
CONFIG += c++11 warn_on exceptions_off rtti_off

SOURCES += main.cpp
DEFINES *= $${COMMON_DEFINES}

RESOURCES += "$${TOP_SRCDIR}/assets/assets.qrc"
OTHER_FILES += qmlplugins.qml


# Linking

include($${TOP_SRCDIR}/src/link_to_backend.pri)
include($${TOP_SRCDIR}/src/link_to_frontend.pri)


# Translations

EXTRA_TRANSLATIONS = $$files($${TOP_SRCDIR}/lang/fvi_*.ts)
CONFIG += lrelease embed_translations

# Deployment

include($${TOP_SRCDIR}/src/deployment_vars.pri)

!isEmpty(INSTALL_DOCDIR) {
    md.files += \
        $${TOP_SRCDIR}/LICENSE.md \
        $${TOP_SRCDIR}/README.md
    md.path = $${INSTALL_DOCDIR}
    OTHER_FILES += $${icon.files}
    INSTALLS += md
}

unix:!macx {
    target.path = $${INSTALL_BINDIR}

    !isEmpty(INSTALL_ICONDIR) {
        icon.files += platform/linux/gg.forbidden.FVI.png
        icon.path = $${INSTALL_ICONDIR}
        OTHER_FILES += $${icon.files}
        INSTALLS += icon
    }
    !isEmpty(INSTALL_DESKTOPDIR) {
        desktop_file.input = platform/linux/gg.forbidden.FVI.desktop.in
        desktop_file.output = $${OUT_PWD}/gg.forbidden.FVI.desktop
        OTHER_FILES += $${desktop_file.input}

        QMAKE_SUBSTITUTES += desktop_file
        desktop.files += $$desktop_file.output
        desktop.path = $${INSTALL_DESKTOPDIR}
        INSTALLS += desktop
    }
    !isEmpty(INSTALL_APPSTREAMDIR) {
        appstream.files += platform/linux/gg.forbidden.FVI.metainfo.xml
        appstream.path = $${INSTALL_APPSTREAMDIR}
        OTHER_FILES += $${appstream.files}
        INSTALLS += appstream
    }
}
win32 {
    QMAKE_TARGET_PRODUCT = "fvi-launcher"
    QMAKE_TARGET_COMPANY = "forbidden.gg"
    QMAKE_TARGET_DESCRIPTION = "FVI Launcher"
    QMAKE_TARGET_COPYRIGHT = "Copyright (c) 2020 Team Forbidden LLC."
    RC_ICONS = platform/windows/app_icon.ico
    OTHER_FILES += $${RC_ICONS}

    target.path = $${INSTALL_BINDIR}
}
macx {
    ICON = platform/macos/fvi-launcher.icns
    QMAKE_APPLICATION_BUNDLE_NAME = FVI
    QMAKE_TARGET_BUNDLE_PREFIX = gg.forbidden
    QMAKE_INFO_PLIST = platform/macos/Info.plist.in

    target.path = $${INSTALL_BINDIR}
}

!isEmpty(target.path): INSTALLS += target
