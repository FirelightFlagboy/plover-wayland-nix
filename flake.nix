{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    plover-update.url = "github:FirelightFlagboy/nixpkgs/update-plover-4.0.0.dev12";
  };

  outputs = { self, nixpkgs, plover-update }:
    let
      system = "x86_64-linux";

      overlay = final: prev: {
        plover.dev = plover-update.legacyPackages.${prev.system}.plover.dev.overrideAttrs (
          old: {
            patches = [
              ./patches/plover/log-steno-engine.patch
            ];
          }
        );
      };

      pkgs = import nixpkgs {
        inherit system;
        overlays = [ overlay ];
      };

      plover-base = pkgs.plover.dev;

      self-pkgs = self.packages.${system};
    in
    {
      packages.${system} = rec {
        plover-wtype-output = pkgs.python310Packages.buildPythonPackage {
          name = "plover-wtype-output";
          src = pkgs.fetchFromGitHub {
            owner = "svenkeidel";
            repo = "plover-wtype-output";
            rev = "b31b9432defa2edbc087d3f36ee2cfec28244873";
            sha256 = "sha256-UlNlGG1ml40bDn1CQnsibXRrshokAnszUQRQZeAm+xs=";
          };

          buildInputs = [ plover-base ];
          dontWrapQtApps = true;
          propagatedBuildInputs = [ pkgs.wtype ];
        };
        plover-dotool-output = pkgs.python310Packages.buildPythonPackage {
          name = "plover-dotool-output";
          src = pkgs.fetchFromGitHub {
            owner = "halbGefressen";
            repo = "plover-output-dotool";
            rev = "25e7df1a116672163256ccef85cfd91f7e76b9cf";
            sha256 = "sha256-Fl4/MmXS3NZqgR1E/vl8iJizSeRyhDLH4bhLy92upqY=";
          };

          patches = [
            ./patches/plover-output-dotool/log-have-output-plugin.patch
            ./patches/plover-output-dotool/missing-set-key-press-delay.patch
          ];

          buildInputs = [ plover-base ];
          dontWrapQtApps = true;
          propagatedBuildInputs = [ pkgs.dotool ];
        };
        plover.dev = plover-base;
        plover-wtype = plover-base.overrideAttrs
          (old: { propagatedBuildInputs = old.propagatedBuildInputs ++ [ plover-wtype-output ]; });
        plover-dotool = plover-base.overrideAttrs
          (old: { propagatedBuildInputs = old.propagatedBuildInputs ++ [ plover-dotool-output ]; });
      };

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [ plover-base self-pkgs.plover-wtype-output self-pkgs.plover-dotool-output ];
      };
    };
}
