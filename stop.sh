#!/bin/bash

SESSION_NAME="minecraft"
LOG_FILE="server.log"

if screen -list | grep -q "\.$SESSION_NAME"; then
    # Create the file that tells start.sh to stop looping
    touch STOP_RESTART
    
    echo "Sending 'stop' command..."
    screen -S $SESSION_NAME -X stuff "stop\015"

    echo "Monitoring shutdown progress (Ctrl+C to stop viewing)..."

    # While 'screen -list' finds the session, keep looping
    while screen -list | grep -q "\.$SESSION_NAME"; do
        clear
        echo "Server is shutting down... (Session: $SESSION_NAME)"
        echo "---------------------------------------------------"
        tail -n 10 "$LOG_FILE"
        echo "---------------------------------------------------"
        echo "Waiting for session to close..."
        sleep 1
    done

    echo "Success: Screen session has terminated."
    # Final cleanup just in case
    rm -f STOP_RESTART

    # --- NEW BACKUP SECTION ---
    echo "Starting GitHub backup..."
    
    # Navigate to the directory just in case
    cd "$(dirname "$0")"

    # Check for changes
    if [[ -n $(git status -s) ]]; then
        git add .
        git commit -m "Server Shutdown Backup: $(date +'%Y-%m-%d %H:%M')"
        git push origin main
        echo "Backup pushed to GitHub successfully!"
    else
        echo "No changes detected in the world. Skipping backup."
    fi
    # ---------------------------

else
    echo "No running server session found."
fi
