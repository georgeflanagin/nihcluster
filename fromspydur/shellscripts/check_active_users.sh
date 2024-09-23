#!/bin/bash

# Function to print usage information
usage() {
  echo "Usage: $0 -g GROUP -y YEARS"
  echo "  -g GROUP    The name of the group to inspect"
  echo "  -y YEARS    The number of years to check for activity"
  exit 1
}

# Parse command-line arguments
while getopts "g:y:" opt; do
  case $opt in
    g)
      group=$OPTARG
      ;;
    y)
      years=$OPTARG
      ;;
    *)
      usage
      ;;
  esac
done

# Check if both arguments are provided
if [ -z "$group" ] || [ -z "$years" ]; then
  usage
fi

# Get the current date and the date specified years ago
current_date=$(date +%s)
time_period_ago=$(date -d "$years years ago" +%s)

# Get the list of users in the specified group
users=$(getent group "$group" | awk -F: '{print $4}' | tr ',' ' ')

# Initialize the count of active users
active_count=0

# Loop through each user
for user in $users; do
  # Get the last login time for the user
  last_login=$(lastlog -u "$user" | awk 'NR==2 {print $4, $5, $9}')
  
  # Convert the last login time to a timestamp
  last_login_timestamp=$(date -d "$last_login" +%s 2>/dev/null)
  
  # If the conversion to timestamp was successful and the user logged in within the specified time period
  if [[ -n "$last_login_timestamp" && "$last_login_timestamp" -ge "$time_period_ago" ]]; then
    active_count=$((active_count + 1))
  fi
done

# Print the number of active users
echo "Number of active users in the '$group' group in the last $years years: $active_count"

