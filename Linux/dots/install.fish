#!/usr/bin/env fish

set script_dir (path dirname (realpath (status filename)))
set nixos_root /etc/nixos

set src $script_dir
set cfg ~/.config

function confirm-overwrite
    set -l target $argv[1]

    if test -e $target
        read -P "Path '$target' exists. Overwrite? [y/N] " ans
        if test "$ans" != y
            echo "Skipping $target"
            return 1
        end
        echo "Removing old $target..."
        rm -rf $target
    end

    return 0
end

# Wallpapers avatar -> ~/.face
set avatar_src $nixos_root/Wallpapers/avatar.jpg
set avatar_dst ~/.face

if test -f $avatar_src
    echo "Using avatar image: $avatar_src"
    cp -f $avatar_src $avatar_dst 2>/dev/null || sudo cp $avatar_src $avatar_dst
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

# Thunar
if confirm-overwrite $cfg/Thunar
    mkdir -p $cfg
    cp -r $src/thunar $cfg/Thunar
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

echo "Configuring Flatpak..."
if command -q flatpak
    echo "Adding Flathub repository..."
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

    echo "Checking Bottles..."
    if not flatpak list --app | grep -q com.usebottles.bottles
        echo "Installing Bottles..."
        sudo flatpak install -y flathub com.usebottles.bottles
    else
        echo "Bottles is already installed."
    end
else
    echo "Flatpak is not installed! Enable 'services.flatpak.enable = true' in your NixOS config first."
end

if confirm-overwrite $cfg/nvim
    echo "Cleaning all Neovim data..."
    rm -rf ~/.local/share/nvim
    rm -rf ~/.local/state/nvim
    rm -rf ~/.cache/nvim

    mkdir -p $cfg
    cp -r $src/nvim $cfg/nvim
    echo "Neovim config installed. Run 'nvim' to download plugins."
end

# Make Hypr scripts executable
if test -f $cfg/hypr/scripts/wsaction.fish
    chmod +x $cfg/hypr/scripts/wsaction.fish
end

echo "✅ Installation complete!"
