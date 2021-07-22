// Pegasus Frontend
// Copyright (C) 2018  Mátyás Mustoha
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.


#include "PreInit.h"

#include "Api.h"
#include "AppSettings.h"
#include "LocaleUtils.h"
#include "Log.h"
#include "Paths.h"
#include "model/gaming/Collection.h"
#include "model/gaming/Game.h"
#include "model/gaming/Assets.h"
#include "model/keys/Key.h"
#include "utils/FolderListModel.h"
#include "steamshim_child.h"

#include "QtQmlTricks/QQmlObjectListModel.h"
#include "SortFilterProxyModel/qqmlsortfilterproxymodel.h"
#include "SortFilterProxyModel/filters/filtersqmltypes.h"
#include "SortFilterProxyModel/proxyroles/proxyrolesqmltypes.h"
#include "SortFilterProxyModel/sorters/sortersqmltypes.h"
#include <QDebug>
#include <QDir>
#include <QGuiApplication>
#include <QQmlEngine>
#include <QSysInfo>
#include <list>


namespace {

void print_metainfo()
{
    Log::info(tr_log("FVI " GIT_REVISION " (" GIT_DATE ")"));
    Log::info(tr_log("Running on %1 (%2, %3)").arg(
        QSysInfo::prettyProductName(),
        QSysInfo::currentCpuArchitecture(),
        QGuiApplication::platformName()));
	    Log::info(tr_log("Qt version %1").arg(qVersion()));
}

void register_api_classes()
{
    // register API classes:
    //   this should come before the ApiObject constructor,
    //   as that may produce language change signals

    constexpr auto API_URI = "Pegasus.Model";
    const QString error_msg = tr_log("Sorry, you cannot create this type in QML.");

    qmlRegisterUncreatableType<model::Collection>(API_URI, 0, 7, "Collection", error_msg);
    qmlRegisterUncreatableType<model::Game>(API_URI, 0, 2, "Game", error_msg);
    qmlRegisterUncreatableType<model::Assets>(API_URI, 0, 2, "GameAssets", error_msg);
    qmlRegisterUncreatableType<model::Locales>(API_URI, 0, 11, "Locales", error_msg);
    qmlRegisterUncreatableType<model::Themes>(API_URI, 0, 11, "Themes", error_msg);
    qmlRegisterUncreatableType<model::Providers>(API_URI, 0, 11, "Providers", error_msg);
    qmlRegisterUncreatableType<model::Key>(API_URI, 0, 10, "Key", error_msg);
    qmlRegisterUncreatableType<model::Keys>(API_URI, 0, 10, "Keys", error_msg);
    qmlRegisterUncreatableType<model::GamepadManager>(API_URI, 0, 12, "GamepadManager", error_msg);

    // QML utilities
    qmlRegisterType<FolderListModel>("Pegasus.FolderListModel", 1, 0, "FolderListModel");

    // third-party
    qmlRegisterUncreatableType<QQmlObjectListModelBase>("QtQmlTricks.SmartDataModels",
                                                        2, 0, "ObjectListModel", error_msg);
    qqsfpm::registerSorterTypes();
    qqsfpm::registerFiltersTypes();
    qqsfpm::registerProxyRoleTypes();
    qqsfpm::registerQQmlSortFilterProxyModelTypes();
}

} // namespace


namespace backend {

PreInit::PreInit(const CliArgs& args)
{
    // Make sure this comes before any file related operations
    AppSettings::general.portable = args.portable;

    Log::init(args.silent);
    print_metainfo();
    AppSettings::load_config();

    register_api_classes();
}

} // namespace backend

// This example assumes you own Postal 1 on Steam...
//
//     http://store.steampowered.com/app/232770
//
//  ...and it will RESET ALL YOUR ACHIEVEMENTS for that game, so BE CAREFUL
//  before running this!



static void printEvent(const STEAMSHIM_Event *e)
{
    if (!e) return;

    printf("CHILD EVENT: ");
    switch (e->type)
    {
        #define PRINTGOTEVENT(x) case SHIMEVENT_##x: printf("%s(", #x); break
        PRINTGOTEVENT(BYE);
        PRINTGOTEVENT(STATSRECEIVED);
        PRINTGOTEVENT(STATSSTORED);
        PRINTGOTEVENT(SETACHIEVEMENT);
        PRINTGOTEVENT(GETACHIEVEMENT);
        PRINTGOTEVENT(RESETSTATS);
        PRINTGOTEVENT(SETSTATI);
        PRINTGOTEVENT(GETSTATI);
        PRINTGOTEVENT(SETSTATF);
        PRINTGOTEVENT(GETSTATF);
        #undef PRINTGOTEVENT
        default: printf("UNKNOWN("); break;
    } /* switch */

    printf("%sokay, ival=%d, fval=%f, time=%llu, name='%s').\n",
            e->okay ? "" : "!", e->ivalue, e->fvalue, e->epochsecs, e->name);
} /* printEvent */

int main(int argc, char **argv)
{
    const int retval = (int) time(NULL) % 127;
    int i;

    printf("Child argv (argc=%d):\n", argc);
    for (i = 0; i <= argc; i++)
        printf("  - '%s'\n", argv[i]);
    printf("\n");

    if (!STEAMSHIM_init())
    {
        printf("Child init failed, terminating.\n");
        return 42;
    } /* if */

    STEAMSHIM_requestStats();
    while (STEAMSHIM_alive())
    {
        const STEAMSHIM_Event *e = STEAMSHIM_pump();
        printEvent(e);
        if (e && e->type == SHIMEVENT_STATSRECEIVED)
            break;
        usleep(100 * 1000);
    } // while

    STEAMSHIM_getStatI("BulletsFired");
    STEAMSHIM_getAchievement("KILL_FIRST_VICTIM");

    STEAMSHIM_resetStats(1);
    STEAMSHIM_storeStats();

    STEAMSHIM_setAchievement("KILL_FIRST_VICTIM", 1);
    STEAMSHIM_getAchievement("KILL_FIRST_VICTIM");
    STEAMSHIM_setStatI("BulletsFired", 22);
    STEAMSHIM_storeStats();

    {
        time_t x = time(NULL) + 5;

        while ( STEAMSHIM_alive() && (time(NULL) < x) )
        {
            const STEAMSHIM_Event *e = STEAMSHIM_pump();
            printEvent(e);
            usleep(100 * 1000);
        } // while
    }

    STEAMSHIM_deinit();

    sleep(3);

    printf("Child returning %d\n", retval);
    return retval;
} /* main */

