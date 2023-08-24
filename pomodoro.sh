#!/bin/bash

# Function to check if notify-send is already installed and install it if not
check_and_install_notify_send() {
    if command -v notify-send &> /dev/null; then
        echo "notify-send is already installed."
    else
        if command -v apt-get &> /dev/null; then
            sudo apt-get update
            sudo apt-get install -y libnotify-bin
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y libnotify
        elif command -v yum &> /dev/null; then
            sudo yum install -y libnotify
        elif command -v brew &> /dev/null; then
            brew install terminal-notifier
        else
            echo "Package manager not found. Please install libnotify (Linux) or terminal-notifier (macOS) manually."
            exit 1
        fi
    fi
}


# Function to start the Pomodoro timer
start_pomodoro_timer() {
    local duration=$1
    local message=$2
    local sound=$3

    echo "Pomodoro timer started for $duration minutes."
    local end_time=$((SECONDS + (duration * 60)))

    while ((SECONDS < end_time)); do
        local remaining_time=$((end_time - SECONDS))
        local minutes=$((remaining_time / 60))
        local seconds=$((remaining_time % 60))
        printf "\rTime remaining: %02d:%02d" "$minutes" "$seconds"
        sleep 1
    done

    echo ""

    if command -v notify-send &> /dev/null; then
        notify-send "Pomodoro Timer" "$message"
    else
        echo "Pomodoro completed: $message"
    fi

    if [[ $sound == "yes" ]]; then
        if command -v afplay &> /dev/null; then
            afplay sound/Alarm.mp3
        else
            echo "Sound notification not available."
        fi
    fi
}

# Prompt for OS choice
read -p "Please select your operating system (Linux/Mac): " os

# Install notify-send based on the chosen OS
case $os in
    Linux)
        check_and_install_notify_send
        ;;
    Mac)
        check_and_install_notify_send
        ;;
    *)
        echo "Invalid choice. Exiting..."
        exit 1
        ;;
esac

# Check and install notify-send if needed
check_and_install_notify_send

# Start the Pomodoro timer
read -p "Enter the duration of the Pomodoro timer (in minutes): " duration
read -p "Enter a message for when the timer completes: " message
read -p "Include sound notification? (yes/no): " sound

start_pomodoro_timer "$duration" "$message" "$sound"