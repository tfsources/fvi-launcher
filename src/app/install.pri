
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
        icon16.files += platform/linux/icons/16/gg.forbidden.FVI.png
        icon32.files += platform/linux/icons/32/gg.forbidden.FVI.png
        icon48.files += platform/linux/icons/48/gg.forbidden.FVI.png
        icon64.files += platform/linux/icons/64/gg.forbidden.FVI.png
        icon128.files += platform/linux/icons/128/gg.forbidden.FVI.png

        icon16.path = $${INSTALL_ICONDIR}/16x16/apps/
        icon32.path = $${INSTALL_ICONDIR}/32x32/apps/
        icon48.path = $${INSTALL_ICONDIR}/48x48/apps/
        icon64.path = $${INSTALL_ICONDIR}/64x64/apps/
        icon128.path = $${INSTALL_ICONDIR}/128x128/apps/

        INSTALLS += icon16 icon32 icon48 icon64 icon128
        OTHER_FILES += $${icon16.files} $${icon32.files} $${icon48.files} $${icon64.files} $${icon128.files}
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
