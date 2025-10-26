# Nextcloud Dual-Boot Integration Project

This repository documents the process of setting up a **Windows + Linux dual-boot workstation** with secure cloud synchronization using **Nextcloud**, **Google Drive**, and **rclone**, plus enhanced MFA security.

## Overview

- **Client:** Private client
- **Goal:** Rebuild and harden a personal workstation for secure file synchronization and authentication.
- **Deliverables:**
  - Re-imaged laptop with Windows 11 and Linux dual boot
  - KDE Plasma desktop on Linux
  - Nextcloud clients on both OSes
  - Cloud integration between Google Drive and Nextcloud
  - Full MFA and hardware key security setup

---

## Documentation

| File | Description |
|------|--------------|
| [`docs/01_system_reimage.md`](docs/01_system_reimage.md) | Step-by-step system reimaging and OS installation |
| [`docs/02_network_troubleshooting.md`](docs/02_network_troubleshooting.md) | Troubleshooting network issues on client laptop and phone |
| [`docs/03_linux_environment.md`](docs/03_linux_environment.md) | Linux desktop and system configuration |
| [`docs/04_nextcloud_integration.md`](docs/04_nextcloud_integration.md) | Nextcloud + Google Drive synchronization setup |
| [`docs/05_security_and_mfa.md`](docs/05_security_and_mfa.md) | MFA, SSH, GPG, and hardware key setup |
| [`docs/06_lessons_learned.md`](docs/06_lessons_learned.md) | What worked well and challenges encountered |
| [`docs/07_future_improvements.md`](docs/07_future_improvements.md) | Possible extensions and automation ideas |

---

## Tech Stack

- **Operating Systems:** Windows 11 + Linux Mint XFCE (KDE Plasma)
- **Tools:** `rclone`, `systemd`, `Nextcloud Desktop`, `YubiKey Manager`
- **Authentication:** ID.me Authenticator (TOTP), YubiKey (FIDO2)
- **Cloud Providers:** The Good Cloud (Nextcloud), Google Drive
- **Security:** SSH (ed25519), GPG (4096-bit), 2FA/MFA across all services

---

## Security Practices

- 2FA (TOTP + hardware key) enforced on all accounts  
- SSH/GPG keys with rotation schedule  
- Encrypted backups of configuration and credentials  
- Linux PAM integration for YubiKey login  
- Password manager recommended: Bitwarden / KeePassXC

---

## Author

**Katherine Dendekker – Cybersecurity Intern**
Cybersecurity & Cloud Systems Engineer  
[https://linkedin.com/in/katherine-dendekker](#)

---

> This repository is for educational and documentation purposes only.
