import QtQuick
import Quickshell
import Quickshell.Io

Item {
  id: root
  property string moduleName: "io.github.bmontythe3rd.display-manager"
  property string helperPath: Quickshell.env("HOME") + "/.config/omarchy/plugins/" + moduleName + "/bin/display-manager"
  property string lastTopology: ""

  function checkTopology() {
    if (!topologyProc.running) {
      topologyProc.command = [helperPath, "topology"]
      topologyProc.running = true
    }
  }

  Component.onCompleted: checkTopology()

  Timer { interval: 4000; running: true; repeat: true; onTriggered: root.checkTopology() }

  Process {
    id: topologyProc
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var value = String(text || "").trim()
        if (!value || value === root.lastTopology) return
        root.lastTopology = value
        matchProc.command = [root.helperPath, "profiles-match"]
        if (!matchProc.running) matchProc.running = true
      }
    }
  }

  Process {
    id: matchProc
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        try {
          var result = JSON.parse(String(text || "{}"))
          if (result.matched) Quickshell.execDetached(["omarchy-notification-send", "-g", "󰍺", "Display profile applied", result.name])
        } catch (e) {}
      }
    }
  }
}
