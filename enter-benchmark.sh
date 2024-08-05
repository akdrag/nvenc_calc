#!/bin/bash

# Function to display the menu
show_menu() {
    echo "Choose an option:"
    echo "1) Benchmark for NVIDIA"
    echo "2) Benchmark for Intel"
    echo "3) Benchmark for AMD"
    echo "4) Exit"
}

# Function to handle user input
read_choice() {
    read -p "Enter your choice [1-4]: " choice
    # Run the common script first
    bash video-download.sh
    case $choice in
        1) bash ./nvenc-benchmark.sh ;;
        2) bash ./quicksync-benchmark.sh ;;
        3) bash ./amf-benchmark.sh ;;
        4) exit 0 ;;
        *) echo "Invalid option. Please try again." ;;
    esac
}

# Main loop
while true; do
    show_menu
    read_choice
done
