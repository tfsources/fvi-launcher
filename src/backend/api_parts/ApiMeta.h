// Pegasus Frontend
// Copyright (C) 2017  Mátyás Mustoha
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


#pragma once

#include <QObject>


namespace ApiParts {

class Meta : public QObject {
    Q_OBJECT

    Q_PROPERTY(bool isLoading READ isLoading NOTIFY loadingComplete)
    Q_PROPERTY(QString gitRevision MEMBER m_git_revision CONSTANT)

public:
    explicit Meta(QObject* parent = 0);

    bool isLoading() const { return m_loading; }

    void setElapsedLoadingTime(qint64);
    void onApiLoadingFinished();

signals:
    void loadingComplete();

private:
    const QString m_git_revision;

    bool m_loading;
    qint64 m_loading_time_ms;
};

} // namespace ApiParts