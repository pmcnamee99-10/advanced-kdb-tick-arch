#!/bin/bash

# kdb.sh - KDB+ Process Manager

# Get ABSOLUTE path to script directory and config
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config.json"

# Check jq
if ! command -v jq &> /dev/null; then
    echo "ERROR: jq required. Install: sudo apt install jq"
    exit 1
fi

# Check config
if [ ! -f "$CONFIG_FILE" ]; then
    echo "ERROR: Config not found: $CONFIG_FILE"
    exit 1
fi

# Read config - use quotes around $CONFIG_FILE everywhere!
BASE_DIR=$(jq -r '.directories.base' "$CONFIG_FILE")
LOG_DIR=$(jq -r '.directories.logs' "$CONFIG_FILE")
DB_DIR=$(jq -r '.directories.db' "$CONFIG_FILE")

mkdir -p "$LOG_DIR" 2>/dev/null
mkdir -p "$DB_DIR" 2>/dev/null

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Functions - ALWAYS use "$CONFIG_FILE" with full path
get_port() { jq -r ".components.$1.port" "$CONFIG_FILE"; }
get_script() { jq -r ".components.$1.script" "$CONFIG_FILE"; }
get_name() { jq -r ".components.$1.name" "$CONFIG_FILE"; }
get_args() { jq -r ".components.$1.args" "$CONFIG_FILE"; }
get_startup_order() { jq -r '.startup_order[]' "$CONFIG_FILE"; }
get_shutdown_order() { jq -r '.shutdown_order[]' "$CONFIG_FILE"; }

is_running() { lsof -i :$1 > /dev/null 2>&1; }
get_pid() { lsof -t -i :$1 2>/dev/null; }

start_component() {
    local comp=$1
    local port=$(get_port $comp)
    local script=$(get_script $comp)
    local name=$(get_name $comp)
    local args=$(get_args $comp)
    local logfile="$LOG_DIR/${comp}_$(date +%Y%m%d).log"
    
    if is_running $port; then
        echo -e "${YELLOW}[$name]${NC} Already running on port $port"
        return 0
    fi
    
    echo -e "${GREEN}[$name]${NC} Starting on port $port..."
    
    # Use pushd/popd instead of cd to preserve directory
    pushd "$BASE_DIR" > /dev/null
    
    if [ "$args" != "" ] && [ "$args" != "null" ]; then
        nohup q $script $args -p $port >> "$logfile" 2>&1 &
    else
        nohup q $script -p $port >> "$logfile" 2>&1 &
    fi
    
    popd > /dev/null
    
    sleep 2
    
    if is_running $port; then
        echo -e "${GREEN}[$name]${NC} Started (PID: $(get_pid $port))"
    else
        echo -e "${RED}[$name]${NC} Failed. Check: $logfile"
    fi
}

stop_component() {
    local comp=$1
    local port=$(get_port $comp)
    local name=$(get_name $comp)
    
    if ! is_running $port; then
        echo -e "${YELLOW}[$name]${NC} Not running"
        return 0
    fi
    
    local pid=$(get_pid $port)
    echo -e "${RED}[$name]${NC} Stopping PID $pid..."
    kill $pid 2>/dev/null
    sleep 1
    if is_running $port; then kill -9 $pid 2>/dev/null; fi
    echo -e "${RED}[$name]${NC} Stopped"
}

test_component() {
    local comp=$1
    local port=$(get_port $comp)
    local name=$(get_name $comp)
    
    if is_running $port; then
        echo -e "${GREEN}[RUNNING]${NC} $name | Port: $port | PID: $(get_pid $port)"
    else
        echo -e "${RED}[STOPPED]${NC} $name | Port: $port"
    fi
}

# Main
MODE=$1
COMPONENT=$2

case $MODE in
    start)
        echo "====== STARTING KDB+ COMPONENTS ======"
        if [ "$COMPONENT" == "all" ] || [ -z "$COMPONENT" ]; then
            for comp in $(get_startup_order); do
                start_component $comp
                sleep 1
            done
        else
            start_component $COMPONENT
        fi
        echo "======================================="
        ;;
    stop)
        echo "====== STOPPING KDB+ COMPONENTS ======"
        if [ "$COMPONENT" == "all" ] || [ -z "$COMPONENT" ]; then
            for comp in $(get_shutdown_order); do
                stop_component $comp
            done
        else
            stop_component $COMPONENT
        fi
        echo "======================================="
        ;;
    test|status)
        echo "====== KDB+ STATUS ======"
        echo "Config: $CONFIG_FILE"
        echo "Base:   $BASE_DIR"
        echo "Logs:   $LOG_DIR"
        echo "-------------------------"
        for comp in $(get_startup_order); do
            test_component $comp
        done
        echo "========================="
        ;;
    *)
        echo "Usage: $0 [start|stop|test] [all|tp|rdb1|rdb2|cep|feed]"
        ;;
esac