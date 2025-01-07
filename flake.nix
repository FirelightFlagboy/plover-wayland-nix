{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      system = "x86_64-linux";

      pkgsPrePatch = import nixpkgs {
        inherit system;
      };

      patches = [
        # Update plover from 4.0.0.dev10 to 4.0.0.dev12
        (pkgsPrePatch.fetchpatch {
          url = "https://github.com/NixOS/nixpkgs/commit/37f589b5fef07ea8bb110afac4abc13a1f7e59a9.patch";
          sha256 = "1bmn11dggzk3j59pzxl9gsryl35njblm3h6ag5v87wsga1ph1001";
        })
        # Update plover from 4.0.0.dev12 to 4.0.0.rc2
        (pkgsPrePatch.fetchpatch {
          url = "https://github.com/NixOS/nixpkgs/commit/634e203d1c07115763a5759b53ce4e9805c8663a.patch";
          sha256 = "1zh4gilpr29f381aa51a3irv13cxybp4rcdi1fww1ihh54yhmk37";
        })
        # Remove `plover.stable`
        (pkgsPrePatch.fetchpatch {
          url = "https://github.com/NixOS/nixpkgs/pull/303669/commits/30ef197717d8ec87fab88c56e63e4a347bf90e31.patch";
          sha256 = "01aqbglla8wvvj6ppy9vim6gj6zyxcqja47bsflpjc5nark666hp";
        })
      ];

      pkgsPatched = pkgsPrePatch.applyPatches {
        src = pkgsPrePatch.path;
        inherit patches;
      };
      pkgs = import pkgsPatched {
        inherit system;
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

          buildInputs = [ plover-base ];
          dontWrapQtApps = true;
          propagatedBuildInputs = [ pkgs.dotool ];
        };
        plover.dev = plover-base;
        plover-wtype = plover-base.overrideAttrs (old: {
          propagatedBuildInputs = old.propagatedBuildInputs ++ [ plover-wtype-output ];
        });
        plover-dotool = plover-base.overrideAttrs (old: {
          propagatedBuildInputs = old.propagatedBuildInputs ++ [ plover-dotool-output ];
        });
      };

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          plover-base
          self-pkgs.plover-wtype-output
          self-pkgs.plover-dotool-output
        ];
      };
    };
}
