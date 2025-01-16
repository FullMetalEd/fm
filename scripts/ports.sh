#!bin/bash
# ---
# Name: ports
# Description: Shows a list of the ports in use on the pc and lists their processes.
# Usage: ports
# Example ports
# ---


# Define the ports function
ports() {
    # Determine whether to use ss or netstat based on their availability
    local cmd
    if command -v ss > /dev/null 2>&1; then
        cmd="sudo ss -tulnp"
    elif command -v netstat > /dev/null 2>&1; then
        cmd="netstat -tuln"
    else
        echo "Error: Neither 'ss' nor 'netstat' command is available."
        return 1
    fi

    # Print the header with tabs for column spacing
    echo -e "Protocol\t\tPort\tPID/Program name\t\t\t\tAddress"
    echo -e "--------\t\t----\t----------------\t\t\t\t-------"

    # Execute the selected command and pipe the output to awk for processing
    $cmd | awk 'NR>1 {  # Process each line except the header (NR>1)
        split($5, addr, ":");  # Split the address field at the colon
        port = addr[length(addr)];  # Get the port number
        proto = $1;  # First field: Protocol (tcp/udp)

        # Set pidprog based on whether ss or netstat is used
        pidprog = ($0 ~ /users:/) ? $7 : "N/A";

        # Print the line with colored output and formatted columns
        printf "\033[1;34m%-8s\033[1;32m%-8s\033[0;31m%-40s\033[0;37m\t%s\n",
               proto,    # Protocol in blue
               port,     # Port in green
               pidprog,  # PID/Program name in default color
               $5;       # Address
    }'
}