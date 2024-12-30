# Cronjobs-in-Docker
This repository shows how to construct a lightweight alpine docker container and running/scheduling cronjobs within that Docker container, it is important to note that the script.sh file and the python script (should there be one) have to be located at the same directory level as the dockerfile in order to work.
Note that both the Dockerfile and the script.sh produce individual log files separately from one another. Once the container is up and running these log files can be found in `/var/log/`.
The code above produces a total of two logs as output, the Dockerfile produces a cron.log while the script produces a script.log

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
## Running a Python Script
### 1. Running Python code directly via cron in Docker
Dockerfile
```
# Use a lightweight Linux distribution as a base
FROM python:3.11-alpine

# Install cron and any other dependencies
RUN apk update && apk add --no-cache cronie

# Install Python packages (if necessary)
RUN pip install --no-cache-dir external-package-you-want-to-install

# Copy the Python script into the container
COPY script.py /usr/local/bin/script.py

# Add the cron job directly to the root's crontab
RUN echo "* * * * * python3 /usr/local/bin/script.py >> /var/log/cron.log 2>&1" > /etc/crontabs/root

# Create the log file & make sure it's accessible
RUN touch /var/log/cron.log

# Start the cron service when the container starts
CMD ["crond", "-f", "-s"]
```
Any output produced by the python file will be directly piped and appended over to the /var/log/cron.log file here

Python Script
```
# script.py
import datetime

with open("/var/log/script.log", "a") as log_file:
    log_file.write(f"This Python script ran at {datetime.datetime.now()}\n")
```

### 2. Running Python script via a Shell script in Docker
Dockerfile
```
# Use a lightweight Linux distribution as a base
FROM python:3.11-alpine

# Install cron and any other dependencies
RUN apk update && apk add --no-cache bash cronie

# Install Python packages (if necessary)
RUN pip install --no-cache-dir external-package-you-want-to-install

# Copy the Python script and shell script into the container
COPY script.py /usr/local/bin/script.py
COPY script.sh /usr/local/bin/script.sh

# Make sure the shell script is executable
RUN chmod +x /usr/local/bin/script.sh

# Add the cron job that runs the shell script, since the shell script below already directs output into script.log we can discard output here
RUN echo "* * * * * /usr/local/bin/script.sh >> /dev/null 2>&1" > /etc/crontabs/root

# Create the log file & make sure it's accessible
RUN touch /var/log/cron.log

# Start the cron service when the container starts
CMD ["crond", "-f", "-s"]
```

Shell script
```
#!/bin/bash

# Run python script and then append logs to /var/log/script.log 
python3 /usr/local/bin/script.py >> /var/log/script.log 2>&1
```

*Python script is the same as the first example*

#### Log errors and discard regular output
`RUN echo "* * * * * /usr/local/bin/script.sh > /dev/null 2>> /var/log/script-errors.log" > /etc/crontabs/root`
