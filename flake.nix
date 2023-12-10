{
  description = "hackathon 23 winter team 1 playground";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-23.11";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { nixpkgs, flake-utils, rust-overlay, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
        toolchain = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
        rustPlatform = pkgs.makeRustPlatform {
          rustc = toolchain;
          cargo = toolchain;
        };
        nativeBuildInputs = with pkgs; [ pkg-config ];
        buildInputs = with pkgs; [ openssl libiconv ] ++ lib.optionals stdenvNoCC.isDarwin [ darwin.Security ];
      in
      {
        devShells.default = pkgs.stdenv.mkDerivation {
          name = "rocket-sandbox";
          nativeBuildInputs = nativeBuildInputs ++ [ toolchain ];
          inherit buildInputs;
        };
        packages.default = rustPlatform.buildRustPackage {
          pname = "rocket-sandbox";
          version = "0.1.0";
          src = ./.;
          cargoLock.lockFile = ./Cargo.lock;
          inherit nativeBuildInputs buildInputs;
          doCheck = false;
          buildType = "debug";
        };
      }
    );
}
