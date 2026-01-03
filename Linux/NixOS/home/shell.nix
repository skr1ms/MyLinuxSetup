{ config, pkgs, inputs, system, ... }:

let
  quickshellPkg = inputs.quickshell.packages.${system}.default;
in
{
  programs.caelestia = {
    enable = true;

    systemd = {
      enable = false;
      target = "graphical-session.target";
    };

    cli = {
      enable = true;
      settings.theme.enableGtk = false;
    };

    settings = {
      # --- General ---
      general.apps = {
        terminal = [ "foot" ];
        audio    = [ "pavucontrol" ];
        playback = [ "mpv" ];
        explorer = [ "thunar" ];
      };

      general.battery = {
        warnLevels = [
          {
            level = 20;
            title = "Low battery";
            message = "You might want to plug in a charger";
            icon = "battery_android_frame_2";
          }
          {
            level = 10;
            title = "Did you see the previous message?";
            message = "You should probably plug in a charger <b>now</b>";
            icon = "battery_android_frame_1";
          }
          {
            level = 5;
            title = "Critical battery level";
            message = "PLUG THE CHARGER RIGHT NOW!!";
            icon = "battery_android_alert";
            critical = true;
          }
        ];
        criticalLevel = 3;
      };

      general.idle = {
        lockBeforeSleep = true;
        inhibitWhenAudio = true;
        timeouts = [
            { timeout = 180; idleAction = "lock"; }
            { timeout = 300; idleAction = "dpms off"; returnAction = "dpms on"; }
            { timeout = 600; idleAction = [ "systemctl" "suspend-then-hibernate" ]; }
        ];
      };

      # --- Appearance ---
      appearance = {
        anim.durations.scale = 1;
        padding.scale = 1;
        rounding.scale = 1;
        spacing.scale = 1;
        
        font = {
          family = {
            clock    = "JetBrains Mono";
            material = "Material Symbols Rounded";
            mono     = "JetBrainsMono Nerd Font";
            sans     = "JetBrains Mono";
          };
          size.scale = 1;
        };

        transparency = {
            enabled = true;
            base = 0.85;
            layers = 0.4;
        };
      };

      # --- Paths ---
      paths = {
        wallpaperDir = "~/Pictures/Wallpapers";
        # mediaGif = "root:/assets/bongocat.gif"; 
        # sessionGif = "root:/assets/kurukuru.gif";
      };

      # --- Bar ---
      bar = {
        persistent = true;
        dragThreshold = 20;
        showOnHover = true;

        entries = [
          { id = "logo";         enabled = true; }
          { id = "workspaces";   enabled = true; }
          { id = "spacer";       enabled = true; }
          { id = "activeWindow"; enabled = true; }
          { id = "spacer";       enabled = true; }
          { id = "tray";         enabled = true; }
          { id = "clock";        enabled = true; }
          { id = "statusIcons";  enabled = true; }
          { id = "power";        enabled = true; }
        ];

        popouts = {
            activeWindow = true;
            statusIcons = true;
            tray = true;
        };

        workspaces = {
          activeIndicator = true;
          activeLabel = "󰮯";
          activeTrail = false;
          label = "  ";
          occupiedBg = false;
          occupiedLabel = "󰮯";
          perMonitorWorkspaces = true;
          showWindows = true;
          shown = 5;
          specialWorkspaceIcons = [
              { name = "steam"; icon = "sports_esports"; }
          ];
        };

        status = {
          showAudio = false;
          showBattery = true;
          showBluetooth = true;
          showKbLayout = false;
          showMicrophone = false;
          showNetwork = true;
          showLockStatus = true;
        };

        tray = {
            background = false;
            compact = false;
            iconSubs = [];
            recolour = false;
        };

        scrollActions = {
          brightness = true;
          workspaces = true;
          volume = true;
        };
        
        excludedScreens = [ "" ];
        activeWindow.inverted = false;
        clock.showIcon = true;
      };

      # --- Background ---
      background = {
          enabled = true;
          desktopClock.enabled = false;
          visualiser = {
              blur = false;
              enabled = false;
              autoHide = true;
              rounding = 1;
              spacing = 1;
          };
      };

      # --- Dashboard ---
      dashboard = {
          enabled = true;
          dragThreshold = 50;
          mediaUpdateInterval = 500;
          showOnHover = true;
      };

      # --- OSD ---
      osd = {
        enabled = true;
        enableBrightness = true;
        enableMicrophone = false;
        hideDelay = 2000;
      };

      # --- Session ---
      session = {
        enabled = true;
        dragThreshold = 30;
        vimKeybinds = false;
        commands = {
          logout   = [ "pkill" "-KILL" "-u" "takuya" ];
          shutdown = [ "systemctl" "poweroff" ];
          suspend  = [ "systemctl" "suspend" ];
          reboot   = [ "systemctl" "reboot" ];
          hibernate = [ "systemctl" "hibernate" ]; 
        };
      };

      # --- Services ---
      services = {
        audioIncrement = 0.1;
        maxVolume = 1.0;
        defaultPlayer = "Spotify";
        gpuType = "";
        playerAliases = [{ from = "com.github.th_ch.youtube_music"; to = "YT Music"; }];
        weatherLocation = "Moscow";
        useFahrenheit = false;
        useTwelveHourClock = false;
        smartScheme = true;
        visualiserBars = 45;
      };

      # --- Launcher ---
      launcher = {
        actionPrefix = ">";
        dragThreshold = 50;
        vimKeybinds = false;
        enableDangerousActions = false;
        maxShown = 7;
        maxWallpapers = 9;
        specialPrefix = "@";
        showOnHover = false;
        hiddenApps = [];
        
        useFuzzy = {
            apps = false;
            actions = false;
            schemes = false;
            variants = false;
            wallpapers = false;
        };

        actions = [
            {
                name = "Calculator";
                icon = "calculate";
                description = "Do simple math equations (powered by Qalc)";
                command = ["autocomplete" "calc"];
                enabled = true;
                dangerous = false;
            }
            {
                name = "Scheme";
                icon = "palette";
                description = "Change the current colour scheme";
                command = ["autocomplete" "scheme"];
                enabled = true;
                dangerous = false;
            }
            {
                name = "Wallpaper";
                icon = "image";
                description = "Change the current wallpaper";
                command = ["autocomplete" "wallpaper"];
                enabled = true;
                dangerous = false;
            }
        ];
      };

      # --- Sidebar ---
      sidebar = {
          dragThreshold = 80;
          enabled = true;
      };

      # --- Utilities & Notifs ---
      utilities = {
        enabled = true;
        maxToasts = 4;
        toasts = {
            audioInputChanged = true;
            audioOutputChanged = true;
            capsLockChanged = true;
            chargingChanged = true;
            configLoaded = true;
            dndChanged = true;
            gameModeChanged = true;
            kbLayoutChanged = true;
            numLockChanged = true;
            vpnChanged = true;
            nowPlaying = true;
        };
        vpn = {
            enabled = false;
            provider = [];
        };
      };

      notifs = {
          actionOnClick = false;
          clearThreshold = 0.3;
          defaultExpireTimeout = 5000;
          expandThreshold = 20;
          openExpanded = false;
          expire = false;
      };
      
      border = {
        rounding = 25;
        thickness = 10;
      };
      
      lock.recolourLogo = false;
    };
  };

  home.packages = [ quickshellPkg ];
}

