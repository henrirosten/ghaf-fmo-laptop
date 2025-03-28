# Copyright 2022-2025 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{ inputs, ... }:
{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    # Ghaf imports
    inputs.ghaf.nixosModules.microvm
    inputs.ghaf.nixosModules.disko-debug-partition
    inputs.ghaf.nixosModules.profiles
    inputs.ghaf.nixosModules.profiles-laptop
    inputs.ghaf.nixosModules.reference-appvms
    inputs.ghaf.nixosModules.reference-profiles
    inputs.ghaf.nixosModules.reference-programs
    inputs.ghaf.nixosModules.reference-services
    inputs.ghaf.nixosModules.reference-personalize

    # FMO imports
    inputs.self.nixosModules.host
    inputs.self.nixosModules.fmo-services
  ];

  config = {
    ghaf = {
      # Ghaf platform profile
      profiles = {
        laptop-x86 = {
          enable = true;
          netvmExtraModules = [
            # Ghaf imports
            inputs.ghaf.nixosModules.reference-services
            inputs.ghaf.nixosModules.reference-personalize
            { ghaf.reference.personalize.keys.enable = true; }

            # FMO imports
            inputs.self.nixosModules.netvm
            inputs.self.nixosModules.fmo-services
          ];
          guivmExtraModules = [
            # Ghaf imports
            inputs.ghaf.nixosModules.reference-programs
            inputs.ghaf.nixosModules.reference-personalize
            { ghaf.reference.personalize.keys.enable = true; }

            # FMO imports
            inputs.self.nixosModules.guivm
          ];
        };
        graphics.enable = true;
      };

      graphics = {
        labwc = {
          autolock.enable = lib.mkForce true;
          autologinUser = lib.mkForce null;
        };
      };

      # Enable shared directories for the selected VMs
      virtualization.microvm-host.sharedVmDirectory.vms = [
        "chrome-vm"
      ];

      virtualization.microvm.appvm = {
        enable = true;
        vms =
          {
            chrome.enable = true;
            zathura.enable = true;
          }
          // (import ../modules/microvm/docker/vm.nix { inherit pkgs lib config; })
          // (import ../modules/microvm/msg/vm.nix { inherit pkgs lib config; });
      };

      # Content
      reference = {
        appvms.enable = true;
        desktop.applications.enable = true;

        services = {
          enable = true;
          google-chromecast = true;
        };

        personalize = {
          keys.enable = true;
        };
      };

      # TODO: this is the debug partitioning for the ghaf
      # it allows read and write. Production should use the read-only version
      # that is coming with dm-verity
      partitioning.disko.enable = true;
    };
  };
}
