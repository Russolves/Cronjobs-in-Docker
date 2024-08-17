# Use a lightweight Linux distribution as a base
FROM alpine:latest

# Install necessary packages: cron and any other dependencies
RUN apk update && apk add bash curl nano cronie

# Copy your script into the container
COPY script.sh /usr/local/bin/script.sh

# Make sure the script is executable
RUN chmod +x /usr/local/bin/script.sh

# Add the cron job
RUN echo "* * * * * /usr/local/bin/script.sh >> /var/log/cron.log 2>&1" > /etc/crontabs/root

# Create the log file & make sure it's accessible
RUN touch /var/log/cron.log

# Start the cron service with syslog logging enabled
CMD ["crond", "-f", "-s"]
