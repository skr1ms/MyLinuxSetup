# NixOS Configuration

NixOS configuration with Hyprland window manager based on [caelestia-dots](https://github.com/caelestia-dots) and [meowrch](https://github.com/meowrch).

## Important Notes

### Password Change

Change the user password in `configuration.nix` before system installation. Locate the following line:

```nix
initialPassword = "your_password_here";
```

Replace `"your_password_here"` with your desired password.

### PostgreSQL

After system installation, change the PostgreSQL user password:

```bash
sudo -u postgres psql
```

```sql
ALTER USER postgres WITH PASSWORD 'your_password_here';
\q
```

Replace `'your_password_here'` with your password.

### Display Resolution

This configuration is optimized for 2560x1600 display resolution. Other resolutions may require additional adjustments in display parameters.

## Installation

### New System Installation

1. Partition disk according to your requirements

2. Mount partitions to `/mnt` and necessary subdirectories (e.g., `/mnt/boot` for EFI)

3. Clone repository:
   ```bash
   git clone https://github.com/skr1ms/MyLinuxSetup.git
   ```

4. Generate hardware configuration:
   ```bash
   sudo nixos-generate-config --root /mnt
   ```

5. Copy configuration files:
   ```bash
   sudo cp -r MyLinuxSetup/* /mnt/etc/nixos/
   ```

6. Navigate to configuration directory and remove unnecessary files:
   ```bash
   cd /mnt/etc/nixos
   sudo rm LICENSE README.md
   ```

7. Edit `configuration.nix` and change `initialPassword` to your password

8. Generate flake.lock:
   ```bash
   sudo nix --extra-experimental-features 'nix-command flakes' flake check
   ```

9. Install system:
   ```bash
   sudo nixos-install --flake .#NixOS
   ```

10. After first login, apply Hyprland configuration:
    ```bash
    fish /etc/nixos/dots/install.fish
    ```

### Existing System Installation

1. Navigate to configuration directory:
   ```bash
   cd /etc/nixos
   ```

2. Clone repository:
   ```bash
   git clone https://github.com/skr1ms/MyLinuxSetup.git
   ```

3. Copy configuration files:
   ```bash
   sudo cp -r MyLinuxSetup/* /etc/nixos/
   ```

4. Remove unnecessary files:
   ```bash
   sudo rm LICENSE README.md
   ```

5. Edit `configuration.nix` and change `initialPassword` to your password

6. Validate configuration:
   ```bash
   sudo nix --extra-experimental-features 'nix-command flakes' flake check
   ```

7. Apply configuration:
   ```bash
   sudo nixos-rebuild switch --flake .#NixOS
   ```

8. Apply Hyprland configuration:
   ```bash
   fish dots/install.fish
   ```

9. Reboot system:
   ```bash
   sudo reboot
   ```

## Regional Restrictions

Users in the Russian Federation must comment out the following packages in `home.nix` and `configuration.nix` due to regional restrictions:

```nix
# vmware-workstation  # Line 241 - configuration.nix
# jetbrains.datagrip  # Line 113 - home.nix
```

These packages require VPN/VPS for installation in Russia.

## Structure

```
.
├── configuration.nix    # System configuration
├── home.nix            # Home Manager configuration
├── flake.nix           # Flake configuration
├── hardware-configuration.nix  # Auto-generated hardware config
├── dots/               # Dotfiles directory
│   └── install.fish    # Installation script for user configs
└── grub-theme/         # GRUB theme files
```

## Features

- Hyprland compositor with Wayland support
- SDDM display manager with Astronaut theme
- Fish shell with Starship prompt
- PostgreSQL 17 database server
- Podman containerization (Docker-compatible)
- Full development environment (Go, Node.js, Python, Java)
- Kubernetes tools (kubectl, helm, k9s)
- Virtual machine support (libvirt, VirtualBox, VMware)

## Credits

Based on configurations from:
- [caelestia-dots](https://github.com/caelestia-dots)
- [meowrch](https://github.com/meowrch)

## License

GPL-3.0
