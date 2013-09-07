import QtQuick 2.0
import Ubuntu.Components 0.1

Column {
    width: parent.width
    Repeater{
        model: 24 // hour in a day

        delegate: Rectangle {
            width: parent.width
            height: units.gu(10)
            color: ( index % 2 == 0) ? "#4c875b" : "#86c07f"
            Label{
                id: timeLabel

                // TRANSLATORS: this is a time formatting string,
                // see http://qt-project.org/doc/qt-5.0/qtqml/qml-qtquick2-date.html#details for valid expressions
                text: new Date(0, 0, 0, index).toLocaleTimeString(Qt.locale(), i18n.tr("hh ap"))
                color:"white"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                fontSize: "x-large"
                opacity: 0.3
            }
        }
    }
}