#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QIcon>
#include "AudioController.h"
#include "Track.h"
#include "LibraryModel.h"
#include "RecommendationManager.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    app.setWindowIcon(QIcon(":/assests/app_icon.ico"));

    // Register C++ types with QML
    qmlRegisterType<AudioController>("com.finix.audioplayer", 1, 0, "AudioController");
    qmlRegisterType<LibraryModel>("com.finix.audioplayer", 1, 0, "LibraryModel");

    // Register uncreatable types (for property types only)
    qmlRegisterUncreatableType<Track>("com.finix.audioplayer", 1, 0, "Track",
                                      "Track cannot be created from QML");
    qmlRegisterUncreatableType<RecommendationManager>("com.finix.audioplayer", 1, 0, "RecommendationManager",
                                                     "RecommendationManager cannot be created from QML");

    QQmlApplicationEngine engine;

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    engine.load(url);

    if (engine.rootObjects().isEmpty()) {
        qWarning() << "Failed to load QML";
        return -1;
    }

    return app.exec();
}
