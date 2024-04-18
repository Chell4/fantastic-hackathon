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

      pkgsLinux = import nixpkgs { system = "x86_64-linux"; };

      backMod = pkgs.buildGoModule {
        name = "back";

        src = ./.;

        vendorHash = null;
      };
      
      backContainer = pkgs.dockerTools.buildImage {
        name = "back-container";

        config = {
          Cmd = [
            "${backMod}/bin/back"
          ];
        };
      };
      
      dbContainer = pkgs.dockerTools.buildImageWithSettings {
        name = "db";

        baseImage = pkgs.dockerTools.alpineImage {
          tag = "latest";
          extraConfig = ''
            RUN apk add --no-cache postgresql;
          '';
        };

        cmd = [];
        portMappings = [{
          hostPort = 5432;
          containerPort = 5432;
        }];

        entryPoint = "postgres";

        volumes = ["${pkgs.writeText "pg_hba.conf" ''
          local all all trust
        ''}" "/tmp/pgdata/pg_hba.conf"];
      };
    in
    {
      packages = {
        default = backContainer;
        db = dbContainer;
      };

      devShells = {
        default = pkgs.mkShell {
          packages = with pkgs; [
            go
          ];
        };
      };
    });
}