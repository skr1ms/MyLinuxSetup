{ pkgs, ... }:

let
  grubThemeSource = ../grub-theme;
in
{
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [ 
      "acpi_osi=Linux" 
      "acpi_backlight=native" 
    ];
    
    tmp.cleanOnBoot = true;

    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };

      grub = {
        enable = true;
        efiSupport = true;
        device = "nodev";
        useOSProber = true;
        configurationLimit = 10;
        gfxmodeEfi = "2560x1600";
        theme = "/boot/grub/themes/grub-theme";
      };
    };
  };

  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 32 * 1024;
  }];

  system.activationScripts.copyGrubTheme = ''
    if [ -d "${grubThemeSource}" ]; then
      mkdir -p /boot/grub/themes
      ${pkgs.rsync}/bin/rsync -aq --delete "${grubThemeSource}/" /boot/grub/themes/grub-theme/
    fi
  '';
}
