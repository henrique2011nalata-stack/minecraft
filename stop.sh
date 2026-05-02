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
        # Clear the terminal so it looks like a live feed
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
else
    echo "No running server session found."
fi
