{ config, pkgs, lib, ... }:
{
  age.secrets.taigaEnv = {
    file = ../../secrets/taiga-secrets.age;
    mode = "0444";
  };

  project.name = "taiga";
  services = let
    backVols = [
      "/var/lib/taiga/static-data:/taiga-back/static"
      "/var/lib/taiga/media-data:/taiga-back/media"
    ];
  in {
    taiga-db.service = {
      image = "postgres:12.3";
      env_file = config.age.secrets.taigaEnv.path;
      volumes = [ "/var/lib/taiga/postgres-data:/var/lib/postgresql/data" ];
    };

    taiga-back.service = {
      image = "taigaio/taiga-back:latest";
      env_file = config.age.secrets.taigaEnv.path;
      volumes = backVols;
      depends_on = [ taiga-db taiga-events-rabbitmq taiga-async-rabbitmq ]
    };

    taiga-async.service = {
      image = "taigaio/taiga-back:latest";
      entrypoint = "/taiga-back/docker/async_entrypoint.sh";
      env_file = config.age.secrets.taigaEnv.path;
      volumes = backVols;
      depends_on = [ taiga-db taiga-back taiga-async-rabbitmq ];
    };

    taiga-async-rabbitmq.service = {
      image = "rabbitmq:3-management-alpine";
      env_file = config.age.secrets.taigaEnv.path;
      volumes = [ "/var/lib/taiga/async-rabbitmq-data:/var/lib/rabbitmq" ];
    };

    taiga-front.service = {
      image = "taigaio/taiga-front:latest";
      env_file = config.age.secrets.taigaEnv.path;
      volumes = [ "/var/lib/taiga/front/conf.json:/usr/share/nginx/html/conf.json" ];
    };

    taiga-events.service = {
      image = "taigaio/taiga-events:latest";
      env_file = config.age.secrets.taigaEnv.path;
      depends_on = [ taiga-events-rabbitmq ];
    };

    taiga-events-rabbitmq.service = {
      image = "rabbitmq:3-management-alpine";
      env_file = config.age.secrets.taigaEnv.path;
      volumes = [ "/var/lib/taiga/events-rabbitmq-data:/var/lib/rabbitmq" ];
    };

    taiga-protected.service = {
      image = "taigaio/taiga-protected:latest";
      environment = {
        MAX_AGE = 360;
      };
      env_file = config.age.secrets.taigaEnv.path;
    };

    taiga-gateway.service = {
      image = "nginx:1.19-alpine";
      ports = [ "9000:80" ];
      volumes = backVols ++ [ "/var/lib/taiga/gateway/taiga.conf:/etc/nginx/conf.d/default.conf" ];
      depends_on = [ taiga-front taiga-back taiga-events ];
    };
  };
}
