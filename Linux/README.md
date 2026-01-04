# NixOS Configuration

NixOS configuration with Hyprland window manager based on [caelestia-dots](https://github.com/caelestia-dots) and [meowrch](https://github.com/meowrch).

This configuration uses a modular file structure for better maintainability and organization.

## System Requirements

- **Display Resolution**: Optimized for 2560x1600. Other resolutions may require adjustments in display parameters.
- **Architecture**: x86_64 Linux
- **Minimum Disk Space**: 300GB recommended
- **Network**: Internet connection required for initial installation

## Pre-Installation Configuration

### Bootloader Selection (GRUB vs Secure Boot)

**Dual Boot Windows + NixOS**: Supports GRUB and Secure Boot (lanzaboote).

**Location**: `system/boot/` directory, select one in `configuration.nix`

#### GRUB (Default)

```
imports = [ ./system/boot/grub.nix ]; # Comment secure.nix
```

#### Secure Boot (lanzaboote)

**These parameters may vary depending on the motherboards, but the essence remains the same, you need to enable secure boot and clear the keys. My example is explained based on the asus prime z790-p motherboard.**

**How to Enable Secure Boot (Step-by-Step):**

1. Prepare BIOS:

   Enter BIOS → Secure Boot.

   Select "Clear Secure Boot Keys" (Reset to Setup Mode).

   Set OS Type to Windows UEFI Mode. 

   Set Key Management to Custom (if available). 

   Save & Exit.

2. Install Lanzaboote in NixOS:

   Edit configuration.nix: Enable secure.nix, disable grub.nix.

   ```
   imports = [ ./system/boot/secure.nix ]; # Comment grub.nix 
   ```

   Rebuild system:

   ```
   sudo nixos-rebuild boot --install-bootloader --flake .#NixOS
   ```

**After lanzaboote install (one-time)**:

```
sudo sbctl create-keys
sudo sbctl enroll-keys --microsoft
```

#### Migrating from GRUB (Troubleshooting)

**If GRUB still appears or boots instead of Lanzaboote:**

1. Remove old GRUB entry from NVRAM:

   ```
   sudo efibootmgr              # Find BootXXXX for GRUB/NixOS
   sudo efibootmgr -b XXXX -B   # Delete it
   ```

2. Reinstall bootloader:

   ```
   sudo nixos-rebuild boot --install-bootloader --flake .#NixOS
   ```

### Regional Restrictions

**Users in the Russian Federation** must comment out `jetbrains.datagrip` before installation due to regional licensing restrictions.

**Location**: `home/apps.nix`, line ~37

# jetbrains.datagrip # Comment this line if installing from Russia

This package requires VPN/VPS connection for installation within the Russian Federation.

### Internet Censorship Circumvention (DPI Bypass)

**Users in Russia**: This configuration includes a pre-configured `zapret` service to bypass DPI censorship (YouTube, Discord, etc.).

**Location**: `services/zapret.nix`

- **Enabled by default**: The service is active out of the box.
- **Strategy**: Configured with `fake,multidisorder` strategy which works on most Russian ISPs (including MGTS/GPON).
- **Customization**: If you experience issues, edit `NFQWS_OPT_DESYNC` in `services/zapret.nix`.

### GPU Configuration (NVIDIA / AMD)

This configuration includes support for NVIDIA GPUs but requires manual activation depending on your hardware.

**Location**: `system/hardware.nix` (or wherever you placed the GPU config)

Uncomment the NVIDIA drivers section in your config file before installation:

```
services.xserver.videoDrivers = [ "nvidia" ];

hardware.nvidia = {
  modesetting.enable = true;
  powerManagement.enable = false;
  powerManagement.finegrained = false;
  open = false;
  nvidiaSettings = true;
  package = config.boot.kernelPackages.nvidiaPackages.stable;
};
```

### Password Configuration

**CRITICAL**: Change the default user password before system installation.

**Location**: `users/takuya.nix`

```
initialPassword = "your_password_here";  # Replace with your secure password
```

### PostgreSQL Security

After system installation, immediately change the PostgreSQL superuser password:

```
sudo -u postgres psql -p 5442
```

```
ALTER USER postgres WITH PASSWORD 'your_secure_password';
\q
```

## Installation Procedures

### Method 1: Fresh System Installation

1. **Prepare Installation Media**

   - Boot from NixOS live USB
   - Verify network connectivity: `ping nixos.org`

2. **Partition and Mount Disk**

   ```
   # Example partition scheme (adjust to your needs)
   # /dev/sda1: 512M EFI partition
   # /dev/sda2: Remaining space for root

   mkfs.fat -F 32 /dev/sda1
   mkfs.ext4 /dev/sda2

   mount /dev/sda2 /mnt
   mkdir -p /mnt/boot
   mount /dev/sda1 /mnt/boot
   ```

3. **Clone Repository**

   ```
   git clone https://github.com/skr1ms/MySetup.git
   cd MySetup
   ```

4. **Generate Hardware Configuration**

   ```
   sudo nixos-generate-config --root /mnt
   ```

5. **Deploy Configuration Files**

   ```
   sudo cp -r Linux/NixOS/* /mnt/etc/nixos/

   # Remove documentation files
   cd /mnt/etc/nixos
   sudo rm -f LICENSE README.md
   ```

6. **Configure User Credentials**

   ```
   sudo nano /mnt/etc/nixos/users/takuya.nix
   # Change initialPassword value
   ```

7. **Verify Configuration**

   ```
   cd /mnt/etc/nixos
   sudo nix --extra-experimental-features 'nix-command flakes' flake check
   ```

8. **Install System**

   ```
   sudo nixos-install --flake .#NixOS
   ```

9. **Post-Installation Setup**
   ```
   # After reboot and login
   fish /etc/nixos/dots/install.fish
   ```

### Method 2: Existing NixOS System Migration

1. **Backup Current Configuration**

   ```
   sudo cp -r /etc/nixos /etc/nixos.backup
   ```

2. **Clone Repository**

   ```
   cd /tmp
   git clone https://github.com/skr1ms/MySetup.git
   ```

3. **Preserve Hardware Configuration**

   ```
   sudo cp /etc/nixos/hardware-configuration.nix /tmp/hw-backup.nix
   ```

4. **Deploy New Configuration**

   ```
   sudo rm -rf /etc/nixos/*
   sudo cp -r MySetup/Linux/NixOS/* /etc/nixos/
   sudo cp /tmp/hw-backup.nix /etc/nixos/hardware-configuration.nix

   # Remove documentation
   cd /etc/nixos
   sudo rm -f LICENSE README.md
   ```

5. **Configure User Password**

   ```
   sudo nano /etc/nixos/users/takuya.nix
   # Update initialPassword
   ```

6. **Validate and Apply**

   ```
   sudo nix --extra-experimental-features 'nix-command flakes' flake check
   sudo nixos-rebuild switch --flake .#NixOS
   ```

7. **Apply Desktop Configuration**

   ```
   fish /etc/nixos/dots/install.fish
   ```

8. **Reboot System**
   ```
   sudo reboot
   ```

## Configuration Structure

```
Linux/NixOS/
├── configuration.nix             # Main entry point, imports all modules
├── flake.nix                     # Nix flake configuration with inputs
├── hardware-configuration.nix    # Auto-generated, machine-specific (do not version control)
│
├── system/                       # Core system configuration
    ├── boot/                     # 
│   │   ├── grub.nix                    # Kernel, bootloader, GRUB theme
    │   └── secure.nix                  # Secure Boot (lanzaboote) if u using dualboot with secure boot
│   ├── locale.nix                # Timezone, i18n, keyboard layout
│   ├── networking.nix            # Network, firewall, DNS
│   ├── security.nix              # Polkit, SSH daemon
│   ├── power.nix                 # Power management, backlight
│   ├── hardware.nix              # Graphics, Bluetooth
│   └── nix.nix                   # Nix settings, garbage collection, overlays
│
├── services/                     # System services
│   ├── display.nix               # SDDM, Hyprland
│   ├── databases.nix             # PostgreSQL, MySQL, Redis (optional)
│   ├── observability.nix         # Grafana, Prometheus, Loki (disabled by default)
│   ├── virtualization.nix        # Docker, Podman, libvirt, VirtualBox
│   ├── system-services.nix       # D-Bus, GVFS, NetworkManager applet
│   └── zapret.nix                # DPI Bypass (YouTube/Discord fix)
│
├── programs/                     # Program configurations
│   ├── desktop.nix               # Thunar file manager
│   ├── gaming.nix                # Steam, GameMode
│   ├── shell.nix                 # Fish shell
│   ├── development.nix           # nix-ld libraries for development
│   └── system-tools.nix          # ADB, VPN tools
│
├── packages/                     # Package lists
│   ├── system-packages.nix       # Core system utilities
│   ├── dev-tools.nix             # Development tools (Go, Node, K8s, etc.)
│   └── fonts.nix                 # Font packages
│
├── users/                        # User management
│   └── takuya.nix                # User configuration, groups, activation scripts
│
├── home/                         # Home Manager configuration
│   ├── home.nix                  # Caelestia shell configuration
│   ├── desktop.nix               # GTK, Qt, cursor themes
│   ├── apps.nix                  # GUI applications
│   └── dev-packages.nix          # Python packages and development tools
│
├── dots/                         # User dotfiles
│   └── install.fish              # Dotfiles installation script
│
├── grub-theme/                   # GRUB bootloader theme
└── Wallpapers/                   # Wallpaper collection
```

## Key Features

### Desktop Environment

- **Compositor**: Hyprland (Wayland)
- **Display Manager**: SDDM with Astronaut theme
- **Shell**: Fish with Starship prompt
- **File Manager**: Thunar with plugins
- **Theme**: Dark theme (Papirus icons, Bibata cursors, adw-gtk3)

### Development Environment

- **Languages**: Go, Node.js, TypeScript, Python, Java
- **Databases**: PostgreSQL 17 (port 5442), MySQL/MariaDB (port 3316)
- **Containers**: Docker, Podman (Docker-compatible)
- **Orchestration**: kubectl, helm, k9s, kind, kustomize
- **Tools**: Neovim (nightly), VSCode, Cursor, Android Studio

### Virtualization Support

- libvirtd (KVM/QEMU)
- VirtualBox with Extension Pack
- Docker with custom DNS
- Podman with Docker compatibility layer

### Database Services

- **PostgreSQL 17**: Custom port 5442, remote access enabled
- **MySQL/MariaDB**: Custom port 3316
- **Optional Services** (commented out by default):
  - Redis (port 6389)
  - Memcached
  - ClickHouse (ports 8133, 9010)

### Observability Stack (Optional)

Disabled by default, uncomment in `services/observability.nix`:

- Grafana (port 3010)
- Prometheus (port 9100)
- Loki (port 3110)

## Customization

### Modifying System Configuration

Each module is self-contained and can be edited independently:

1. **Change networking settings**: Edit `system/networking.nix`
2. **Add/remove packages**: Edit appropriate files in `packages/`
3. **Configure services**: Edit files in `services/`
4. **User applications**: Edit `home/apps.nix`

After modifications, rebuild the system:

```
sudo nixos-rebuild switch --flake /etc/nixos#NixOS
```

### Adding New Modules

Create new `.nix` files in appropriate directories and add imports to `configuration.nix`:

```
imports = [
  # ...
  ./your-category/your-module.nix
];
```

## Troubleshooting

### Build Failures

**DataGrip licensing error in Russia**:

```
nano /etc/nixos/home/apps.nix
# Comment out jetbrains.datagrip line
```

**Flake evaluation errors**:

```
sudo nix flake update /etc/nixos
sudo nixos-rebuild switch --flake /etc/nixos#NixOS
```

**Hardware detection issues**:

```
sudo nixos-generate-config --root /mnt --force
```

### Service Issues

**PostgreSQL connection refused**:

```
sudo systemctl status postgresql
sudo journalctl -u postgresql
```

**Hyprland crashes**:

```
# Check logs
journalctl --user -u hyprland
```

## Maintenance

### System Updates

```
# Update flake inputs
sudo nix flake update /etc/nixos

# Rebuild system
sudo nixos-rebuild switch --flake /etc/nixos#NixOS
```

### Garbage Collection

Automatic garbage collection runs daily at 03:15. Manual cleanup:

```
sudo nix-collect-garbage -d
sudo nixos-rebuild boot --flake /etc/nixos#NixOS
```

## Credits

Configuration based on:

- [caelestia-dots](https://github.com/caelestia-dots) - Hyprland shell and desktop environment
- [meowrch](https://github.com/meowrch) - Theme inspiration

## License

GPL-3.0
