{ config, pkgs, ... }:

# Based on
# https://github.com/bol-van/zapret

{
  services.zapret = {
    enable = true;
    udpSupport = true;
    httpSupport = true;
    udpPorts = [ "443" "50000-65535" ];

    params = [
      # TCP (HTTPS)
      "--filter-tcp=80,443"
      "--dpi-desync=fake,multidisorder"
      "--dpi-desync-split-pos=1,midsld"
      "--dpi-desync-repeats=11"
      "--dpi-desync-fooling=badseq"
      "--dpi-desync-fake-tls=0x00000000"
      
      # UDP (QUIC)
      "--new"
      "--filter-udp=443,50000-65535"
      "--dpi-desync=fake"
      "--dpi-desync-repeats=11"
    ];
  };
}

