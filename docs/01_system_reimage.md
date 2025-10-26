# System Reimage and OS Installation

**Project:** Dual-Boot Secure Workstation  
**Engineer:** Katherine Dendekker  
**Date:** October 2025  

---

## Objective

The goal of this phase was to completely re-image the client’s laptop to ensure a clean, secure, and high-performance environment suitable for both business and personal workloads. The system was configured to dual-boot **Windows 11** and **Linux Mint (with KDE Plasma)**, providing flexibility and security for different workflows.

---

## Tools Used

| Tool | Purpose |
|------|----------|
| Ventoy | Create a multiboot USB drive for installation ISOs |
| GParted | Manage and partition the disk |
| Rufus | Prepare Windows 11 ISO if Ventoy unavailable |
| dd (Linux) | Verify ISO integrity |
| GRUB | Bootloader and OS selection |
| UEFI Firmware | Secure Boot configuration |

---

## Pre-Installation Steps

1. **Backup & Verification**
   - Backed up user data from both existing partitions.
   - Verified integrity of downloaded ISO images using SHA256 sums.

2. **Bootable Media Creation**
   - Loaded **Ventoy** onto a 32GB USB drive.
   - Added:
     - `Windows_11.iso`
     - `Linux_Mint_21.3.iso`
   - Verified both booted successfully using a test VM.

3. **BIOS/UEFI Configuration**
   - Entered firmware settings via `F2` at boot.
   - Disabled **Fast Boot**.
   - Enabled **UEFI Mode**.
   - Disabled **Secure Boot** temporarily for installation.
   - Set USB device as first boot priority.

---

## Windows 11 Installation

1. Booted from Ventoy USB and selected **Windows 11 ISO**.  
2. Deleted all existing partitions except the EFI partition if present.  
3. Installed Windows onto unallocated space (roughly 50% of drive).  
4. Allowed Windows to create:
   - System (EFI) partition
   - MSR partition
   - Primary partition  
5. Completed initial setup **offline** (to prevent automatic Microsoft account linkage).  
6. Created local admin user `Admin`.  
7. Verified Windows booted successfully and reserved UEFI entry.

---

## Linux Mint Installation

1. Booted from Ventoy USB and selected **Linux Mint ISO**.  
2. Chose “Install Linux Mint alongside Windows Boot Manager.”  
   - Alternatively, selected **Manual Partitioning**:
     - `/` (root): 100GB, ext4
     - `/home`: Remaining space, ext4
     - `swap`: 8GB
   - Mounted EFI partition at `/boot/efi`.
3. Chose GRUB bootloader installation to the EFI partition.  
4. Proceeded with installation.

---

## Post-Install Configuration

After installation completed:

### 1. Bootloader Verification
   - Rebooted into GRUB menu and confirmed both OS options present.
   - Tested booting each OS successfully.
   - Set default boot entry to **Linux Mint**:
     ```bash
     sudo grub-set-default 0
     sudo update-grub
     ```

### 2. Updates and Package Setup (Linux)
   ```bash
   sudo apt update && sudo apt full-upgrade -y
   sudo apt add-repository universe
   sudo apt install -y git curl rclone nextcloud-desktop kde-plasma-desktop
