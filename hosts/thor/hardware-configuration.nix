{ config, pkgs, lib, ... }:
with lib; {
  imports = [
    # Enables non-free firmware.
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
  ];

  # Use custom linux firmware that has the more recent firmware.
  hardware.firmware = with pkgs; [ firmwareLinuxNonfree ];

  # Use latest kernel.
  #boot.kernelPackages = pkgs.unstable.linuxPackages_latest;

  boot.initrd.availableKernelModules =
    [ "xhci_pci" "nvme" "ahci" "usbhid" "uas" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.extraModulePackages = [ ];
  boot.kernelModules = [ "kvm-amd" "nct6775" "hid-apple" "wireguard" ];
  # Use F keys as default on MacOS keyboards (aka Keychron).
  boot.extraModprobeConfig = ''
    options hid_apple fnmode=2
    options usbhid jspoll=1
  '';
  boot.kernelParams = [ "nomodeset" "acpi_enforce_resources=lax" "mitigations=off" ];

  ## CPU
  nix.maxJobs = lib.mkDefault 32;
  powerManagement.cpuFreqGovernor = "performance";
  hardware.cpu.amd.updateMicrocode = true;

  ## GPU
  services.xserver = {
    videoDrivers = [ "nvidia" ];
    # Disable temporal dithering, just like in Windows. Let the display handle it.
    deviceSection = ''
      Option "FlatPanelProperties" "Dithering=Disabled"
      Option "ModeValidation" "NoEdidHDMI2Check"
      Option "ModeValidation" "AllowNonEdidModes"
      Option "ModeDebug" "true"
    '';
    # 10-bit display.
    #defaultDepth = 30;
  };
  hardware.opengl = {
    enable = true;
    driSupport = true;
    # 32-bit support - not working on nvidia.
    driSupport32Bit = true;
  };
  hardware.nvidia.modesetting.enable = true;

  ## Sound
  # Listen to SPDIF in.
  hardware.pulseaudio.extraConfig = ''
    load-module module-loopback latency_msec=1 source=alsa_input.pci-0000_05_00.0.iec958-stereo
  '';

  ## SSDs
  services.fstrim.enable = true;

  ## Support NTFS volumes.
  boot.supportedFilesystems = [ "ntfs" ];

  ## Boot with UEFI.
  boot.loader = {
    timeout = 3;
    efi.canTouchEfiVariables = true;
    systemd-boot = {
      enable = true;
      # Disable when working - as this allows root access.
      editor = false;
      configurationLimit = 10;
      memtest86.enable = true;
    };
  };

  ## Storage
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-label/BOOT";
      fsType = "vfat";
    };
    "/windows" = {
      device = "/dev/nvme0n1p4";
      fsType = "ntfs";
      options = [ "rw" ];
    };
  };
  swapDevices = [ ];

  ## Networking
  networking.hostName = "thor";
}
