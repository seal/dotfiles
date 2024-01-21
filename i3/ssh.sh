#!/bin/bash

# Prompt for the server
read -p "Enter the server: " server

# Check if the server is not empty
if [ -n "$server" ]; then
    # Run the ssh command with kitty
    kitty +kitten ssh "$server"
else
    echo "Server is required."
fi

