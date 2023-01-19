# This container is meant to be run as a cron job. For docker swarm you can run the following container that take care of scheduling other containers that have the correct labels:
docker service create --name swarm_cronjob \
  --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock \
  --env "LOG_LEVEL=info" \
  --env "LOG_JSON=false" \
  --constraint "node.role == manager" \
  crazymax/swarm-cronjob