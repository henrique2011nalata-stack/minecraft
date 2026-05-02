#!/bin/bash

SESSION_NAME="minecraft"
JAR_PATH="server.jar"
LOG_FILE="server.log"

JAVA_ARGS="-Xms1200M -Xmx1200M -XX:+UseG1GC -XX:ParallelGCThreads=1"

if screen -list | grep -q "\.$SESSION_NAME"; then
    echo "Server is already running! Use 'screen -r $SESSION_NAME' to see it."
else
    [ -f "$LOG_FILE" ] && rm "$LOG_FILE"
    rm -f STOP_RESTART
    
    echo "Launching Minecraft with CPU Priority..."
    
    screen -dmS $SESSION_NAME bash -c "while [ ! -f STOP_RESTART ]; do \
        sudo nice -n -10 ionice -c 1 -n 4 java $JAVA_ARGS -jar $JAR_PATH nogui; \
        if [ ! -f STOP_RESTART ]; then \
            echo 'Restarting in 5s...'; \
            sleep 5; \
        fi; \
    done; rm -f STOP_RESTART"
    
    echo "Monitoring boot sequence..."
    
    while [ ! -f "$LOG_FILE" ]; do sleep 1; done

    until grep -i -q "Done" "$LOG_FILE" 2>/dev/null; do
        clear
        echo "Server is booting up... (Single Core Optimization Active)"
        echo "---------------------------------------------------"
        tail -n 10 "$LOG_FILE"
        sleep 2
    done

    clear
    echo "Server is ONLINE! (Session: $SESSION_NAME)"
    echo "---------------------------------------------------"
    tail -n 10 "$LOG_FILE"
    echo "Startup Complete."
fi
