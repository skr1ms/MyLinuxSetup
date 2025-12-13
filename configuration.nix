{ config, lib, pkgs, inputs, system, ... }:

let
  sddmAstronaut = pkgs.sddm-astronaut.override {
    embeddedTheme = "pixel_sakura";
  };
in
{
  imports = [ ./hardware-configuration.nix ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config = {
    allowUnfree = true;
    android_sdk.accept_license = true;
    permittedInsecurePackages = [
       "electron-25.9.0" 
       "olm-3.2.16"
    ];
  };

  nixpkgs.overlays = [ inputs.antigravity.overlays.default ];

  boot.tmp.cleanOnBoot = true;

  boot.loader.efi = {
    canTouchEfiVariables = true;
    efiSysMountPoint = "/boot";
  };

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    useOSProber = true;
    configurationLimit = 10;
    gfxmodeEfi = "2560x1600";
    theme = "/boot/grub/themes/my-grub-theme";
  };

  networking = {
    hostName = "NixOS";
    
    networkmanager = {
      enable = true;
      wifi = {
        powersave = false;
        macAddress = "preserve";
      };
      plugins = with pkgs; [
        networkmanager-openvpn
        networkmanager-openconnect
      ];
    };

    wireless.enable = false;
    
    # MySQL(3306), PG(5432), Redis(6379), ClickHouse(8123,9000), 
    # Grafana(3000), Prometheus(9090), Loki(3100)
    firewall.allowedTCPPorts = [ 
      3306 5432 6379 8123 9000 3000 9090 3100
    ];
  };

  security.polkit.enable = true;
  
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (subject.isInGroup("networkmanager") &&
          (action.id.indexOf("org.freedesktop.NetworkManager.") == 0)) {
        return polkit.Result.YES;
      }
    });
  '';

  time.timeZone = "Europe/Moscow";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "ruwin_alt_sh-UTF-8";

  services.xserver.enable = false;
  services.power-profiles-daemon.enable = true;

  programs.gpu-screen-recorder.enable = true;
  programs.amnezia-vpn.enable = true;

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 32 * 1024;
    }
  ];

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    package = pkgs.kdePackages.sddm;
    theme = "sddm-astronaut-theme";

    settings = {
      Theme = {
        ThemeDir = "${sddmAstronaut}/share/sddm/themes";
        Current = "sddm-astronaut-theme";
      };
    };

    extraPackages = with pkgs; [
      sddmAstronaut
      qt6.qtsvg
      qt6.qtmultimedia
      qt6.qt5compat
      kdePackages.kirigami-addons
      kdePackages.qqc2-desktop-style
    ];
  };

  services.displayManager.defaultSession = "hyprland";

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  
  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
    ];
  };

  services.gvfs.enable = true; 
  services.tumbler.enable = true;

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib
      zlib
      libpng
      nss
      nspr
      openssl
      libxml2
      dbus
      expat
      libdrm
      libxi
      libxkbfile
      libbsd
      libGL
      libGLU
      libxkbcommon
      xcbutilxrm
      libxcb-keysyms
      libxcb-wm
      libxcb-render-util
      libxcb-image
      libxcb-cursor
      pcre
      libepoxy
      xorg.libX11
      xorg.libXext
      xorg.libXrender
      xorg.libXrandr
      xorg.libXcursor
      xorg.libxcb
      xorg.libXfixes
      xorg.libXcomposite
      pulseaudio
      qt6.qtbase
      qt6.qtwayland
      qt6.qtmultimedia
      qt6.qttools
      qt6.qtdeclarative
    ];
  };

  virtualisation.libvirtd.enable = true;
  virtualisation.vmware.host.enable = true;
  virtualisation.virtualbox.host.enable = true;
  virtualisation.docker.enable = false;

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
    };
  };

  services.blueman.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  hardware.graphics.enable = true;

  nix.gc = {
    automatic = true;
    dates = "03:15";
    options = "-d";
  };

  users.users.takuya = {
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "audio"
      "input"
      "docker"
      "kvm"
      "libvirtd"
      "adbusers"
      "vboxuser"
    ];
    initialPassword = "your_password_here"; # dont forget change password
  };

  system.userActivationScripts = {
    android-adb-fix = {
      text = ''
        mkdir -p ~/Android/Sdk/platform-tools
        rm -f ~/Android/Sdk/platform-tools/adb
        ln -s /run/current-system/sw/bin/adb ~/Android/Sdk/platform-tools/adb
      '';
    };
  };

  # =======================================================
  # DATABASE SERVICES
  # =======================================================

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_17;
    settings.listen_addresses = lib.mkForce "*";
  };

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
  };

  services.redis.servers."default" = {
    enable = true;
    port = 6379;
    bind = "0.0.0.0";
  };

  services.memcached = {
    enable = true;
    maxMemory = 256;
    listen = "0.0.0.0";
  };

  services.clickhouse.enable = true;

  # =======================================================
  # OBSERVABILITY (Grafana, Loki, Prometheus)
  # =======================================================

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "0.0.0.0";
        http_port = 3000;
        domain = "localhost";
      };
    };
  };

  services.prometheus = {
    enable = true;
    port = 9090;
    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [{
          targets = [ "localhost:${toString config.services.prometheus.exporters.node.port}" ];
        }];
      }
    ];
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        port = 9101;
      };
    };
  };

  services.loki = {
    enable = true;
    configuration = {
      server.http_listen_port = 3100;
      auth_enabled = false;
      
      common = {
        ring = {
          instance_addr = "127.0.0.1";
          kvstore.store = "inmemory";
        };
        replication_factor = 1;
        path_prefix = "/var/lib/loki";
      };

      schema_config = {
        configs = [{
          from = "2020-10-24";
          store = "tsdb";
          object_store = "filesystem";
          schema = "v13";
          index = {
            prefix = "index_";
            period = "24h";
          };
        }];
      };

      storage_config = {
        filesystem = {
          directory = "/var/lib/loki/chunks";
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [
    networkmanagerapplet
    libnotify
    git
    kitty
    neovim
    fish
    bash
    curl
    wget
    bat
    procs
    antigravity
    brightnessctl
    ddcutil
    lm_sensors
    inotify-tools
    wireplumber
    postgresql
    sqlite 
    mariadb 
    redis 
    virtualbox
    vmware-workstation
    python3
    pipx
    cmake
    ninja
    imagemagick
    file
    pkg-config
    go
    grpcurl
    mockgen
    go-swagger
    go-swag
    go-mockery
    swagger-codegen
    delve
    protobuf
    protoc-gen-go
    protoc-gen-go-grpc
    buf
    golangci-lint
    nodejs
    yarn
    typescript
    lldb
    jdk
    gdb
    gcc
    libgcc
    terraform
    tflint
    terraform-docs
    ansible
    just
    tree-sitter
    gnumake
    lazydocker
    docker
    docker-compose
    k9s
    kubectl
    kind
    helm
    kustomize
    tilt
    podman
    podman-compose
    glances
    yq-go
    httpie
    tree
    opencv
    jq
    ripgrep
    fd
    fzf
    lazygit
    unzip
    zip
    rar
    trash-cli
    eza
    btop
    htop
  ];

  fonts = {
    enableDefaultPackages = true;

    packages = with pkgs; [
      jetbrains-mono
      nerd-fonts.jetbrains-mono
      nerd-fonts.caskaydia-cove
      nerd-fonts.fira-code
      liberation_ttf
      corefonts
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-emoji-blob-bin
      noto-fonts-color-emoji
      google-fonts
      cascadia-code
      material-design-icons
      material-symbols
      nerd-fonts.symbols-only
      papirus-icon-theme
    ];

    fontconfig = {
      defaultFonts = {
        serif = [ "Liberation Serif" "Times New Roman" ];
        sansSerif = [ "Liberation Sans" ];
        monospace = [
          "JetBrains Mono"
          "JetBrainsMono Nerd Font"
          "Cascadia Code"
          "Liberation Mono"
          "Courier New"
        ];
      };
    };
  };

  programs.fish.enable = true;
  programs.adb.enable = true;
  users.defaultUserShell = pkgs.fish;

  services.dbus.enable = true;
  
  systemd.user.services.nm-applet = {
    description = "NetworkManager Applet";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.networkmanagerapplet}/bin/nm-applet --indicator";
      Restart = "on-failure";
    };
  };

  system.stateVersion = "25.11";
}

