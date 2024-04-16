{
  description = "fantastic hackathon go backend";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: 
    flake-utils.lib.eachDefaultSystem (system:
    let 
      pkgs = import nixpkgs { inherit system; };

      backMod = pkgs.buildGoModule {
        name = "back";

        src = ./.;

        vendorHash = null;
      };

    in
    {
      packages.default = backMod;

      devShells = {
        default = pkgs.mkShell {
          packages = with pkgs; [
            go            
          ];
        };
      };
    });
}
