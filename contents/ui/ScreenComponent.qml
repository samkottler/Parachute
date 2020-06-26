import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: screenItem
    visible: false
    clip: true // Fixes the glitches? The glitches are caused by desktopsBar going out of screen?

    property alias desktopsBarRepeater: desktopsBarRepeater
    property alias bigDesktopsRepeater: bigDesktopsRepeater
    property alias desktopBackground: desktopBackground
    // property alias activitiesBackgrounds: activitiesBackgrounds

    property int desktopsBarHeight: Math.round(height / 6) // valid only if position of desktopsBar is top or bottom
    property int desktopsBarWidth: Math.round(width / 6) // valid only if position of desktopsBar is left or right
    property bool animating: false
    property real ratio: width / height

    property int screenIndex: model.index

    // Repeater {
    //     id: activitiesBackgrounds
    //     model: workspace.activities.length
    PlasmaCore.WindowThumbnail {
        id: desktopBackground
        anchors.fill: parent
        visible: winId !== 0
        opacity: mainWindow.configBlurBackground ? 0 : 1
    }
    // }

    FastBlur {
        id: blurBackground
        anchors.fill: parent
        source: desktopBackground
        radius: 64
        visible: desktopBackground.winId !== 0 && mainWindow.configBlurBackground
        // cached: true
    }

    Rectangle { // To apply some transparency without interfere with children transparency
        id: desktopsBarBackground
        anchors.fill: desktopsBar
        color: "black"
        opacity: 0.1
        visible: mainWindow.configShowDesktopBarBackground
    }

    ScrollView {
        id: desktopsBar
        contentWidth: desktopsWrapper.width
        contentHeight: desktopsWrapper.height
        clip: true

        states: [
            State {
                when: mainWindow.configDesktopBarPosition === Enums.Position.Top || mainWindow.configDesktopBarPosition === Enums.Position.Bottom
                PropertyChanges {
                    target: desktopsBar
                    height: desktopsBarHeight
                    anchors.bottom: mainWindow.configDesktopBarPosition === Enums.Position.Top ? bigDesktops.top : undefined
                    anchors.top: mainWindow.configDesktopBarPosition === Enums.Position.Bottom ? bigDesktops.bottom : undefined
                    anchors.right: parent.right
                    anchors.left: parent.left
                }
            },
            State {
                when: mainWindow.configDesktopBarPosition === Enums.Position.Left || mainWindow.configDesktopBarPosition === Enums.Position.Right
                PropertyChanges {
                    target: desktopsBar
                    width: desktopsBarWidth
                    anchors.bottom: parent.bottom
                    anchors.top: parent.top
                    anchors.right: mainWindow.configDesktopBarPosition === Enums.Position.Left ? bigDesktops.left : undefined
                    anchors.left: mainWindow.configDesktopBarPosition === Enums.Position.Right ? bigDesktops.right : undefined
                }
            }
        ]

        Item { // To centralize children
            id: desktopsWrapper
            width: childrenRect.width + 15
            height: childrenRect.height + 15
            x: desktopsBar.width < desktopsWrapper.width ? 0 : (desktopsBar.width - desktopsWrapper.width) / 2
            y: desktopsBar.height < desktopsWrapper.height ? 0 : (desktopsBar.height - desktopsWrapper.height) / 2
            // anchors.horizontalCenter: parent.horizontalCenter
            // anchors.verticalCenter: parent.verticalCenter

            Repeater {
                id: desktopsBarRepeater
                model: mainWindow.workWithActivities ? workspace.activities.length : workspace.desktops

                DesktopComponent {
                    id: miniDesktop
                    activity: mainWindow.workWithActivities ? workspace.activities[model.index] : ""

                    states: [
                        State {
                            when: mainWindow.configDesktopBarPosition === Enums.Position.Top || mainWindow.configDesktopBarPosition === Enums.Position.Bottom
                            PropertyChanges {
                                target: miniDesktop
                                x: 15 + model.index * (width + 15)
                                y: 15
                                width: (height / screenItem.height) * screenItem.width
                                height: desktopsBar.height - 30
                            }
                        },
                        State {
                            when: mainWindow.configDesktopBarPosition === Enums.Position.Left || mainWindow.configDesktopBarPosition === Enums.Position.Right
                            PropertyChanges {
                                target: miniDesktop
                                x: 15
                                y: 15 + model.index * (height + 15)
                                width: desktopsBar.width - 30
                                height: (width / screenItem.width) * screenItem.height
                            }
                        }
                    ]

                    TapHandler {
                        acceptedButtons: Qt.LeftButton
                        onTapped: workspace.currentDesktop = model.index + 1;
                    }
                }
            }
        }
    }

    SwipeView {
        id: bigDesktops
        anchors.fill: parent
        clip: true
        currentIndex: mainWindow.currentActivityOrDesktop
        orientation: mainWindow.configDesktopBarPosition === Enums.Position.Left ||
                mainWindow.configDesktopBarPosition === Enums.Position.Right ? Qt.Vertical : Qt.Horizontal

        Behavior on anchors.topMargin {
            enabled: mainWindow.easingType !== mainWindow.noAnimation && mainWindow.configDesktopBarPosition === Enums.Position.Top

            NumberAnimation {
                duration: mainWindow.animationsDuration
                easing.type: mainWindow.easingType

                onRunningChanged: {
                    screenItem.animating = running;

                    if (!running && mainWindow.activated && bigDesktops.anchors.margins === 0 && mainWindow.easingType === Easing.InExpo) {
                        mainWindow.deactivate();
                    }
                }  
            }
        }

        Behavior on anchors.bottomMargin {
            enabled: mainWindow.easingType !== mainWindow.noAnimation && mainWindow.configDesktopBarPosition === Enums.Position.Bottom

            NumberAnimation {
                duration: mainWindow.animationsDuration
                easing.type: mainWindow.easingType

                onRunningChanged: {
                    screenItem.animating = running;

                    if (!running && mainWindow.activated && bigDesktops.anchors.margins === 0 && mainWindow.easingType === Easing.InExpo) {
                        mainWindow.deactivate();
                    }
                }   
            }
        }

        Behavior on anchors.leftMargin {
            enabled: mainWindow.easingType !== mainWindow.noAnimation && mainWindow.configDesktopBarPosition === Enums.Position.Left

            NumberAnimation {
                duration: mainWindow.animationsDuration
                easing.type: mainWindow.easingType

                onRunningChanged: {
                    screenItem.animating = running;

                    if (!running && mainWindow.activated && bigDesktops.anchors.margins === 0 && mainWindow.easingType === Easing.InExpo) {
                        mainWindow.deactivate();
                    }
                }
            }
        }

        Behavior on anchors.rightMargin {
            enabled: mainWindow.easingType !== mainWindow.noAnimation && mainWindow.configDesktopBarPosition === Enums.Position.Right

            NumberAnimation {
                duration: mainWindow.animationsDuration
                easing.type: mainWindow.easingType

                onRunningChanged: {
                    screenItem.animating = running;

                    if (!running && mainWindow.activated && bigDesktops.anchors.margins === 0 && mainWindow.easingType === Easing.InExpo) {
                        mainWindow.deactivate();
                    }
                }
            }
        }

        Repeater {
            id: bigDesktopsRepeater
            model: mainWindow.workWithActivities ? workspace.activities.length : workspace.desktops

            Item { // Cannot set geometry of SwipeView's root item
                property alias bigDesktop: bigDesktop

                TapHandler {
                    acceptedButtons: Qt.AllButtons

                    onTapped: {
                        if (mainWindow.selectedClientItem)
                            switch (eventPoint.event.button) {
                                case Qt.LeftButton:
                                    mainWindow.toggleActive();
                                    break;
                                case Qt.MiddleButton:
                                    mainWindow.selectedClientItem.client.closeWindow();
                                    break;
                                case Qt.RightButton:
                                    if (mainWindow.workWithActivities)
                                        if (mainWindow.selectedClientItem.client.activities.length === 0)
                                            mainWindow.selectedClientItem.client.activities.push(workspace.activities[model.index]);
                                        else
                                            mainWindow.selectedClientItem.client.activities = [];
                                    else
                                        if (mainWindow.selectedClientItem.client.desktop === -1)
                                            mainWindow.selectedClientItem.client.desktop = model.index + 1;
                                        else
                                            mainWindow.selectedClientItem.client.desktop = -1;
                                    break;
                            }
                        else 
                            mainWindow.toggleActive();
                    }
                }

                DesktopComponent {
                    id: bigDesktop
                    big: true
                    activity: mainWindow.workWithActivities ? workspace.activities[model.index] : ""
                    anchors.centerIn: parent
                    width: desktopRatio < screenItem.ratio ? parent.width - mainWindow.bigDesktopMargin
                            : parent.height / screenItem.height * screenItem.width - mainWindow.bigDesktopMargin
                    height: desktopRatio > screenItem.ratio ? parent.height - mainWindow.bigDesktopMargin
                            : parent.width / screenItem.width * screenItem.height - mainWindow.bigDesktopMargin

                    property real desktopRatio: parent.width / parent.height
                }
            }
        }

        onCurrentIndexChanged: {
            mainWindow.workWithActivities ? workspace.currentActivity = workspace.activities[currentIndex]
                    : workspace.currentDesktop = currentIndex + 1;
        }
    }

    function showDesktopsBar() {
        switch (mainWindow.configDesktopBarPosition) {
            case Enums.Position.Top:
                bigDesktops.anchors.topMargin = screenItem.desktopsBarHeight;
                break;
            case Enums.Position.Bottom:
                bigDesktops.anchors.bottomMargin = screenItem.desktopsBarHeight;
                break;
            case Enums.Position.Left:
                bigDesktops.anchors.leftMargin = screenItem.desktopsBarWidth;
                break;
            case Enums.Position.Right:
                bigDesktops.anchors.rightMargin = screenItem.desktopsBarWidth;
                break;
        }
    }

    function hideDesktopsBar() {
        bigDesktops.anchors.topMargin = 0;
        bigDesktops.anchors.bottomMargin = 0;
        bigDesktops.anchors.leftMargin = 0;
        bigDesktops.anchors.rightMargin = 0;
    }

    function updateDesktopWindowId() {
        const clients = workspace.clientList(); 
        for (let i = 0; i < clients.length; i++) {
            if (clients[i].desktopWindow && clients[i].screen === screenItem.screenIndex) {
                screenItem.desktopBackground.winId = clients[i].windowId;
                return;
            }
        }
    }

    Component.onCompleted: {
        updateDesktopWindowId();
    }
}