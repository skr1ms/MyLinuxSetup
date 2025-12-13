#!/usr/bin/env fish

set src (pwd)
set cfg ~/.config

function confirm-overwrite
    set -l target $argv[1]

    if test -e $target
        read -P "Path '$target' exists. Overwrite? [y/N] " ans
        if test "$ans" != y
            echo "Skipping $target"
            return 1
        end
        rm -rf $target
    end

    return 0
end

# Wallpapers avatar -> ~/.face
set wp_dir ~/Pictures/Wallpapers
set avatar_src $wp_dir/avatar.jpg
set avatar_dst ~/.face

if test -f $avatar_src
    echo "Using avatar image: $avatar_src"
    cp $avatar_src $avatar_dst
else
    echo "Avatar image not found at $avatar_src, skipping ~/.face"
end

# Hypr
if confirm-overwrite $cfg/hypr
    mkdir -p $cfg
    cp -r $src/hypr $cfg/hypr
end

# Reload Hyprland a few times to apply changes
for i in 1 2 3
    hyprctl reload >/dev/null 2>&1
end

# Starship
if confirm-overwrite $cfg/starship.toml
    mkdir -p $cfg
    cp $src/starship.toml $cfg/starship.toml
end

# Foot
if confirm-overwrite $cfg/foot
    mkdir -p $cfg
    cp -r $src/foot $cfg/foot
end

# Fish
if confirm-overwrite $cfg/fish
    mkdir -p $cfg
    cp -r $src/fish $cfg/fish
end

# Fastfetch
if confirm-overwrite $cfg/fastfetch
    mkdir -p $cfg
    cp -r $src/fastfetch $cfg/fastfetch
end

# Uwsm
if confirm-overwrite $cfg/uwsm
    mkdir -p $cfg
    cp -r $src/uwsm $cfg/uwsm
end

# Btop
if confirm-overwrite $cfg/btop
    mkdir -p $cfg
    cp -r $src/btop $cfg/btop
end

# Nvim
if confirm-overwrite $cfg/nvim
    mkdir -p $cfg
    cp -r $src/nvim $cfg/nvim
end

# Make Hypr scripts executable
if test -f $cfg/hypr/scripts/wsaction.fish
    chmod +x $cfg/hypr/scripts/wsaction.fish
end

# ---------- GTK ----------
set gtk3_dir ~/.config/gtk-3.0
set gtk4_dir ~/.config/gtk-4.0

mkdir -p $gtk3_dir $gtk4_dir

set gtk_settings "[Settings]\n"
set gtk_settings "$gtk_settings gtk-icon-theme-name=Papirus-Dark\n"

printf $gtk_settings >$gtk3_dir/settings.ini
printf $gtk_settings >$gtk4_dir/settings.ini

# ---------- GRUB Theme ----------
echo "Installing GRUB theme..."
set grub_theme_src $src/grub-theme
set grub_theme_dst /boot/grub/themes/my-grub-theme

if test -d $grub_theme_src
    sudo mkdir -p $grub_theme_dst
    sudo cp -r $grub_theme_src/* $grub_theme_dst/
    echo "GRUB theme installed to $grub_theme_dst"
else
    echo "GRUB theme source not found at $grub_theme_src, skipping"
end

# ---------- pgAdmin4 setup ----------
set pg_cfg_dir ~/.config/pgadmin
mkdir -p $pg_cfg_dir

set pg_cfg_file $pg_cfg_dir/config_local.py
if test -e $pg_cfg_file
    echo "pgAdmin config_local.py already exists, skipping"
else
    printf "%s\n" \
        "import os" \
        "" \
        "BASE = os.path.expanduser(\"~/.local/share/pgadmin4\")" \
        "" \
        "if not os.path.exists(BASE):" \
        "    os.makedirs(BASE, exist_ok=True)" \
        "" \
        "DATA_DIR = BASE" \
        "SQLITE_PATH = os.path.join(BASE, \"pgadmin4.db\")" \
        "STORAGE_DIR = os.path.join(BASE, \"storage\")" \
        "" \
        "LOG_DIR = os.path.join(BASE, \"logs\")" \
        "if not os.path.exists(LOG_DIR):" \
        "    os.makedirs(LOG_DIR, exist_ok=True)" \
        "" \
        "LOG_FILE = os.path.join(LOG_DIR, \"pgadmin4.log\")" >$pg_cfg_file
    echo "pgAdmin config_local.py written to $pg_cfg_file"
end

echo "Creating /var/lib/pgadmin and /var/log/pgadmin (sudo)..."
sudo mkdir -p /var/lib/pgadmin /var/log/pgadmin
sudo chown -R (whoami):users /var/lib/pgadmin /var/log/pgadmin

# ---------- Podman as Docker (rootless) ----------
echo "Enabling rootless Podman socket (systemd --user)..."
systemctl --user enable --now podman.socket podman.service >/dev/null 2>&1

# Reload Hyprland a few times to apply changes
for i in 1 2 3
    hyprctl reload >/dev/null 2>&1
end

echo "✅ Installation complete!"
