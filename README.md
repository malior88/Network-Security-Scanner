# Network Security Scanner

## Overview
This project is a **Bash script** designed for automated network reconnaissance and vulnerability assessment. It performs:
- **Network scanning** (TCP & UDP) using `nmap`
- **Weak credential scanning** using `hydra`
- **Vulnerability mapping** using `nmap --script vuln` and `searchsploit`

The script helps security professionals and penetration testers quickly identify vulnerabilities and weak credentials in a target network.

## Features
- **Automated Nmap scanning** (Top 1000 TCP ports & Top 100 UDP ports)
- **Credential brute-force attacks** (SSH, RDP, FTP, Telnet)
- **Custom password lists support**
- **Vulnerability detection and mapping**
- **Results saved and compressed for easy analysis**

## Prerequisites
Ensure you have the following installed on your **Kali Linux** machine:
- `nmap`
- `hydra`
- `searchsploit`
- `zip`

## Installation
Clone the repository and navigate to the directory:
```bash
 git clone https://github.com/yourusername/network-security-scan.git
 cd network-security-scan
 chmod +x scan.sh
```

## Usage
Run the script and follow the prompts:
```bash
./scan.sh
```
### Example Execution
```
Enter network range (e.g., 192.168.1.0/24): 192.168.1.0/24
Enter output directory name: scan_results
Choose scan type: Basic or Full: Full
```
The script will:
1. Scan the network for open ports
2. Attempt weak credential brute force attacks
3. Map vulnerabilities (if Full scan is chosen)
4. Save all results in a compressed zip file

## Output
The script generates:
- `tcp_scan_results.txt` (Nmap TCP scan)
- `udp_scan_results.txt` (Nmap UDP scan)
- `vulnerability_scan_results.txt` (If full scan is chosen)
- `results.zip` (Compressed output folder)

## Disclaimer
This tool is intended for **educational and authorized penetration testing only**. Unauthorized use against networks you do not own is illegal.

---

### License
No license included; feel free to modify and use responsibly.

### Contributions
Pull requests and improvements are welcome!

### Contact
For any issues, open an **issue** on GitHub or reach out via LinkedIn.

---

**Stay ethical and secure!** 🔒

