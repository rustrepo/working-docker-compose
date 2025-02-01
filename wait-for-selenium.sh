#!/bin/sh

echo "Checking Selenium status at http://chrome:4444/status..."

until curl -f http://chrome:4444/status; do
  echo "Waiting for Selenium..."
  sleep 1
done

echo "Selenium is ready!"