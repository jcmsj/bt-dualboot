{
  description = "bt-dualboot";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, flake-utils, poetry2nix }:
    flake-utils.lib.eachDefaultSystem (system:
  let
    # see https://github.com/nix-community/poetry2nix/tree/master#api for more functions and examples.
    pkgs = nixpkgs.legacyPackages.${system};
    inherit (poetry2nix.lib.mkPoetry2Nix { inherit pkgs; }) 
    mkPoetryEnv;
  in
  {
    packages = {
      bt-dualboot = mkPoetryEnv { 
        projectDir = self;
        # add extra dependency libfaketime here
        overrides = self: super: {
          libfaketime = pkgs.libfaketime;
        };
      };
      default = self.packages.${system}.bt-dualboot;
    };
    
    devShells.default = pkgs.mkShell {
      nativeBuildInputs = with pkgs; [
        chntpw
      ];
      buildInputs = with pkgs; [
        self.packages.${system}.bt-dualboot
        poetry
      ];
    };
  });
}
