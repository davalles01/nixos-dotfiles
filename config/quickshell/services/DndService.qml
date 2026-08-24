import QtQuick
import Quickshell

pragma Singleton
Scope {
    property bool dndActive: false
    function toggle() { dndActive = !dndActive }
}
