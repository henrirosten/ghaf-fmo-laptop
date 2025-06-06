# Copyright 2022-2025 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  description = "A Ghaf-based FMO laptop";

  nixConfig = {
    substituters = [
      #"https://prod-cache.vedenemo.dev"
      "https://cache.ssrcdevops.tii.ae"
      "https://ghaf-dev.cachix.org"
      "https://cache.nixos.org"
    ];
    extra-trusted-substituters = [
      #"https://prod-cache.vedenemo.dev"
      "https://cache.ssrcdevops.tii.ae"
      "https://ghaf-dev.cachix.org"
      "https://cache.nixos.org"
    ];
    extra-trusted-public-keys = [
      "prod-cache.vedenemo.dev~1:JcytRNMJJdYJVQCYwLNsrfVhct5dhCK2D3fa6O1WHOI="
      "cache.ssrcdevops.tii.ae:oOrzj9iCppf+me5/3sN/BxEkp5SaFkHfKTPPZ97xXQk="
      "ghaf-dev.cachix.org-1:S3M8x3no8LFQPBfHw1jl6nmP8A7cVWKntoMKN3IsEQY="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];

    allow-import-from-derivation = false;
  };

  inputs = {

    #TODO: this needs to be pinned to the version that ghaf is currently pinned to.
    # rather painful. though it can be pinned to official releases this way.
    nixpkgs = {
      url = "github:NixOS/nixpkgs?rev=e06158e58f3adee28b139e9c2bcfcc41f8625b46";
    };

    ghaf = {
      #url = "flake:mylocalghaf";
      url = "github:tiiuae/ghaf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    onboarding-agent = {
      url = "git+ssh://git@github.com/tiiuae/onboarding-agent";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "ghaf/flake-utils";
      };
    };

    ###
    # Flake and repo structuring configurations
    ###
    # Format all the things
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };

    # To ensure that checks are run locally to enforce cleanliness
    git-hooks-nix = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-root.url = "github:srid/flake-root";

    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ###
    ### End of Flake and repo structuring configurations
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
      ];
      imports = [
        ./modules/flake-module.nix
        ./nix/flake-module.nix
        ./overlays/flake-module.nix
        ./targets/flake-module.nix
        ./packages/flake-module.nix
      ];
    };
}
