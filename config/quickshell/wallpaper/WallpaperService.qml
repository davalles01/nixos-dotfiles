pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
  id: root

  property list<string> wallpapers: []
  property string currentWallpaper: ""
  property string backend: "hyprpaper"

  // Scan wallpaper directories
  Process {
    id: scanner
    command: ["sh", "-c",
      "find ~/Wallpapers ~/Pictures -maxdepth 2 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \\) 2>/dev/null | sort -u | head -200"
    ]
    running: false
    stdout: SplitParser {
      onRead: data => {
        const path = data.trim();
        if (path !== "") {
          root.wallpapers = [...root.wallpapers, path];
        }
      }
    }
  }

  // Load saved wallpaper path
  FileView {
    id: configFile
    path: Quickshell.env("HOME") + "/nixos-dotfiles/config/hypr/wallpaper.conf"
    onTextChanged: {
      const saved = configFile.text().trim();
      if (saved !== "") root.currentWallpaper = saved;
    }
  }

  Component.onCompleted: {
    scanner.running = true;
  }

  function rescan() {
    wallpapers = [];
    scanner.running = true;
  }

  function setWallpaper(path) {
	  const oldWallpaper = currentWallpaper;
	  currentWallpaper = path;

	  setProcess.command = [
		"sh", "-c",
		`
		  hyprctl hyprpaper preload "${path}" &&
		  hyprctl hyprpaper wallpaper ",${path}"
		`
	  ];

	  setProcess.running = true;

	  saveProcess.command = [
		  "sh", "-c",
		`
			printf "%s" "${path}" > "$HOME/nixos-dotfiles/config/hypr/wallpaper.conf"

			cat > "$HOME/nixos-dotfiles/config/hypr/hyprpaper.conf" <<EOF
			preload = ${path}
			wallpaper = ,${path}
			splash = false
			EOF 
		`
	  ];

	  saveProcess.running = true;
  }

  Process {
    id: setProcess
    command: []
    running: false
  }

  Process {
    id: saveProcess
    command: []
    running: false
  }
}
