# Cronjobs-in-Docker
This repository shows how to construct a simple alpine docker container and running/scheduling cronjobs within that container.
Note that both the Dockerfile and the script.sh produce individual log files separately from each other. Once the container is up and running these log files can be found in `/var/log/` 
The Dockerfile produces a cron.log while the script produces a script.log

## CLI command to build and run docker container
```
docker build -t cron-job .
docker run -d --name cron-container cron-job
```
To check logs to this container
`docker logs -f cron-container`

To stop and remove container
```
docker stop cron-container
docker rm cron-container
```

## How to check both logs
### 1. Viewing the Dockerfile container log
To check the log that contains the cron job's output
#### Inside the container:
```
docker exec -it cron-container /bin/sh
cat /var/log/cron.log
```
Or if you want to follow the log as new entries are added
```
docker exec -it cron-container /bin/sh
tail -f /var/log/cron.log
```
#### Copying to the Host:
```
docker cp cron-container:/var/log/cron.log /path/to/destination/on/host/
cat /path/to/destination/on/host/cron.log
```

### 2. Viewing the Script specific log (script.sh)
To check the log that contains the specific output from the script
#### Inside the container:
```
docker exec -it cron-container /bin/sh
cat /var/log/script.log
```
Or if you want to follow the log as new entries are added
```
docker exec -it cron-container /bin/sh
tail -f /var/log/script.log
```
