{ config, pkgs, inputs, system, lib, ... }:

let
  quickshellPkg = inputs.quickshell.packages.${system}.default;
in
{
  imports = [
    inputs.caelestia-shell.homeManagerModules.default
  ];

  home.username = "takuya";
  home.homeDirectory = "/home/takuya";
  home.stateVersion = "25.11";

  gtk = {
    enable = true;
    
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };

    cursorTheme = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
    };

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style.name = "adwaita-dark";
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  wayland.windowManager.hyprland.enable = false;

  programs.caelestia = {
    enable = true;

    systemd = {
      enable = true;
      target = "graphical-session.target";
      environment = [ ];
    };

    cli = {
      enable = true;        
      settings.theme.enableGtk = false;
    };

    settings = {
      paths.wallpaperDir = "~/Pictures/Wallpapers";

      general.apps = {
        terminal = [ "foot" ];
        audio    = [ "pavucontrol" ];
        playback = [ "mpv" ];
        explorer = [ "thunar" ];
      };

      bar = {
        persistent = true;
        entries = [
          { id = "logo";         enabled = true; }
          { id = "workspaces";   enabled = true; }
          { id = "spacer";       enabled = true; }
          { id = "activeWindow"; enabled = true; }
          { id = "tray";         enabled = true; }
          { id = "clock";        enabled = true; }
          { id = "statusIcons";  enabled = true; }
          { id = "power";        enabled = true; }
        ];
      };

      appearance.font.family = {
        clock    = "JetBrains Mono";
        material = "Material Symbols Rounded";
        mono     = "JetBrainsMono Nerd Font";
        sans     = "JetBrains Mono";
      };

      session = {
        enabled = true;
        dragThreshold = 30;
        vimKeybinds = false;
        commands = {
          logout   = [ "pkill" "-KILL" "-u" "takuya" ];
          shutdown = [ "systemctl" "poweroff" ];
          suspend  = [ "systemctl" "suspend" ];
          reboot   = [ "systemctl" "reboot" ];
        };
      };
    };
  };

  home.pointerCursor = {
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  programs.waybar.enable = lib.mkForce false;

  home.packages = with pkgs; [
    quickshellPkg
    cava networkmanager app2unit aubio
    pipewire material-symbols swappy libqalculate
    bash bibata-cursors amnezia-vpn hyprland
    xdg-desktop-portal-hyprland xdg-desktop-portal-gtk hyprpicker wl-clipboard
    libreoffice-qt6-fresh onlyoffice-desktopeditors spotify telegram-desktop
    pwvucontrol vencord vesktop tmux
    dbeaver-bin jetbrains.datagrip pgadmin4
    yaak insomnia warp-terminal
    vscode code-cursor flutter
    android-studio-full scrcpy podman-desktop
    steam grim slurp
    wtype pamixer pavucontrol playerctl
    foot firefox google-chrome starship
    fastfetch bulky adw-gtk3 qtcreator
    qalculate-gtk hyprlock hypridle hyprpaper uwsm

    (python3.withPackages (ps: with ps; [
      pip setuptools wheel build
      fastapi uvicorn django flask starlette
      jinja2 requests httpx aiohttp websockets
      sqlalchemy asyncpg psycopg2 psycopg alembic
      redis pymongo motor
      python-dotenv pydantic pydantic-settings
      pyyaml toml
      numpy pandas scipy matplotlib seaborn
      plotly scikit-learn
      notebook jupyterlab ipykernel ipython
      pyside6 pyqt5 pyqt6 pillow
      rich click typer loguru tqdm
      python-multipart
      ruff black isort mypy pylint
      autopep8 flake8
      pytest pytest-asyncio pytest-cov pytest-mock
      faker hypothesis
      pika celery kombu
      trio anyio
      httptools uvloop
      msgpack orjson
      python-dateutil pytz arrow
      cryptography pyjwt passlib bcrypt
      prometheus-client opentelemetry-api
      protobuf grpcio grpcio-tools
    ]))
  ];

  home.activation.copyWallpapers = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    WALLS_SRC="${./Wallpapers}"
    WALLS_DST="${config.home.homeDirectory}/Pictures/Wallpapers"

    mkdir -p "$WALLS_DST"
    if [ -d "$WALLS_SRC" ]; then
      cp -n "$WALLS_SRC"/* "$WALLS_DST" 2>/dev/null || true
    fi
  '';
}

