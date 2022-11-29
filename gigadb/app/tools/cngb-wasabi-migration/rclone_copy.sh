#!/usr/bin/env bash

# Bail out upon error
set -e

# Allow all scripts to base themselves from the directory where backup script 
# is located
APP_SOURCE=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Setup logging
LOGDIR="$APP_SOURCE/logs"
LOGFILE="$LOGDIR/migration_$(date +'%Y%m%d_%H%M%S').log"
mkdir -p $LOGDIR
touch $LOGFILE

# Default is to use copy TEST data to dev directory in Wasabi
SOURCE_PATH="/app/tests/data/cngbdb/giga/gigadb/pub/10.5524"
DESTINATION_PATH="wasabi:gigadb-datasets/dev/pub/10.5524"

# If we're on the backup server then source proxy settings to perform 
# data transfer as determined by its expected hostname
if [ "$HOST_HOSTNAME" == "cngb-gigadb-bak" ];
then
    source "$APP_SOURCE/proxy_settings.sh" || exit 1
    echo "$(date +'%Y/%m/%d %H:%M:%S') DEBUG  : Sourced proxy settings for CNGB backup server" >> "$LOGFILE"
fi

# Exit if no command line parameters provided
if [ $# -eq 0 ]; then
    echo "No arguments provided - exiting..."
    exit 1
fi

# Parse DOIs command line parameters
while [[ $# -gt 0 ]]; do
    case "$1" in
    --starting-doi)
        starting_doi=$2
        shift
        ;;
    --ending-doi)
        ending_doi=$2
        shift
        ;;
    # Option to force use of live data on backup server and force file copying
    # to live directory in Wasabi
    --use-live-data)
        # Ensure we are on backup server otherwise there is no access to live data
        if [ "$HOST_HOSTNAME" == "cngb-gigadb-bak" ];
        then
            # Use path to the mounted real data on backup server
            SOURCE_PATH="/live-data/gigadb/pub/10.5524"
            # And copy to live directory on Wasabi if on backup server
            DESTINATION_PATH="wasabi:gigadb-datasets/live/pub/10.5524"
            echo "$(date +'%Y/%m/%d %H:%M:%S') INFO  : Updated paths to data for CNGB backup server" >> "$LOGFILE"
        else
            echo "Cannot copy live data if we are not on backup server - exiting..."
            exit 1
        fi
        ;;
    *)
        echo "Invalid option: $1"
        exit 1  ## Could be optional.
        ;;
    esac
    shift
done

echo "$(date +'%Y/%m/%d %H:%M:%S') DEBUG  : Begin new batch migration to Wasabi" >> "$LOGFILE"
echo "$(date +'%Y/%m/%d %H:%M:%S') INFO  : Starting DOI is: $starting_doi" >> "$LOGFILE"
echo "$(date +'%Y/%m/%d %H:%M:%S') INFO  : Ending DOI is: $ending_doi" >> "$LOGFILE"

# Check batch size between DOIs
batch_size="$(($ending_doi-$starting_doi))"
if [ "$batch_size" -gt 100 ];
then
    echo "$(date +'%Y/%m/%d %H:%M:%S') ERROR  : Batch size is more that 100 - please reduce size of batch to copy!" >> "$LOGFILE"
    exit
fi

# Determine DOI range directory to use based on starting DOI
if [ "$starting_doi" -lt 101000 ];
then
    dir_range="100001_101000"
elif [ "$starting_doi" -lt 102000 ] && [ "$starting_doi" -gt 101001 ];
then
    dir_range="101001_102000"
elif [ "$starting_doi" -lt 103000 ] && [ "$starting_doi" -gt 102001 ];
then
    dir_range="102001_103000"
fi

# Copy dataset files for all DOIs between starting and ending DOIs
current_doi="$starting_doi"
while [ "$current_doi" -lt "$ending_doi" ] || [ "$current_doi" -eq "$ending_doi" ]
do
    echo "$(date +'%Y/%m/%d %H:%M:%S') INFO  : Assessing DOI: $current_doi" >> "$LOGFILE"
  
    # Create directory paths
    source_dataset_path="${SOURCE_PATH}/${dir_range}/${current_doi}"
    destination_dataset_path="${DESTINATION_PATH}/${dir_range}/${current_doi}"

    # Check directory for current DOI exists
    if [ -d "$source_dataset_path" ]; then
        echo "$(date +'%Y/%m/%d %H:%M:%S') DEBUG  : Found directory $source_dataset_path" >> "$LOGFILE"
        echo "$(date +'%Y/%m/%d %H:%M:%S') INFO  : Attempting to copy dataset ${current_doi} to ${destination_dataset_path}"  >> "$LOGFILE"

        # Perform data transfer to Wasabi
        rclone copy "$source_dataset_path" "$destination_dataset_path" \
            --create-empty-src-dirs \
            --log-file="$LOGFILE" \
            --log-level INFO \
            --stats-log-level DEBUG >> "$LOGFILE"

        # Check exit code for rclone command
        if [ $? -eq 0 ] 
        then 
            echo "$(date +'%Y/%m/%d %H:%M:%S') INFO  : Successfully copied files to Wasabi for DOI: $current_doi" >> "$LOGFILE"
        else 
            echo "$(date +'%Y/%m/%d %H:%M:%S') ERROR  : Problem with copying files to Wasabi by rclone: " >&2 >> "$LOGFILE"
        fi
    fi

    # Increment current DOI
    ((current_doi=current_doi+1))
done

echo "$(date +'%Y/%m/%d %H:%M:%S') INFO  : Finished batch copy process to Wasabi" >> "$LOGFILE"



