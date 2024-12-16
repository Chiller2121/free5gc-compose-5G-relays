#!/bin/bash

# Host to ping; default is google.com if no argument is provided
HOST=${1:-google.com}

# Temporary file to store RTT values
RTT_FILE=$(mktemp)

# Function to clean up temporary file on exit
cleanup() {
  rm -f "$RTT_FILE"
}
trap cleanup EXIT

# Run ping and capture output in real-time
echo "Pinging $HOST..."
ping -I uesimtun0 -c 100 $HOST | tee >(grep -oP '(?<=time=)[0-9.]+' >> "$RTT_FILE")

# Read RTT values from the temporary file
if [[ ! -s "$RTT_FILE" ]]; then
  echo "No RTT values found. Please check your network connection or the hostname."
  exit 1
fi

# Convert RTT values into an array
RTT_ARRAY=($(cat "$RTT_FILE"))

echo "RTT Values: ${RTT_ARRAY[@]}"


# Sort RTT values correctly using sort -n
SORTED_RTT=($(printf "%s\n" "${RTT_ARRAY[@]}" | LC_ALL=C sort -n))

echo "Sorted RTT Values: ${SORTED_RTT[@]}"

# Calculate min, max, and median
MIN_RTT=${SORTED_RTT[0]}
MAX_RTT=${SORTED_RTT[-1]}
COUNT=${#SORTED_RTT[@]}

if (( COUNT % 2 == 0 )); then
  MID=$((COUNT / 2))
  MEDIAN_RTT=$(echo "scale=2; (${SORTED_RTT[$MID-1]} + ${SORTED_RTT[$MID]}) / 2" | bc)
else
  MID=$((COUNT / 2))
  MEDIAN_RTT=${SORTED_RTT[$MID]}
fi

# Calculate average RTT
SUM=0
for RTT in "${RTT_ARRAY[@]}"; do
  SUM=$(echo "$SUM + $RTT" | bc)
done
AVG_RTT=$(echo "scale=2; $SUM / $COUNT" | bc)

# Display the results
echo
echo "Ping statistics for $HOST:"
echo "Min RTT: $MIN_RTT ms"
echo "Max RTT: $MAX_RTT ms"
echo "Median RTT: $MEDIAN_RTT ms"
echo "Average RTT: $AVG_RTT ms"
