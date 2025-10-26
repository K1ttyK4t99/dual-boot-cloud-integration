# Network Troubleshooting – Windows Partition and Mobile DNS Repair

**Project:** Dual-Boot Secure Workstation  
**Engineer:** Katherine Dendekker  
**Date:** October 2025

---

## Objective

Document the steps used to restore and stabilize network functionality on the **Windows 11** partition of an HP laptop and on a **Motorola Stylus 5G** smartphone. The laptop required vendor drivers to be installed; the phone experienced DNS resolution failures preventing Nextcloud sync.

---

## Summary of Actions

- Identified missing/faulty network drivers on Windows via Device Manager.  
- Downloaded chipset, Wi-Fi, Ethernet, and Bluetooth drivers from HP Support and installed them in the correct order.  
- Verified connectivity and, when necessary, reset the Windows network stack (winsock/IP/DNS).  
- Performed a network reset on the Motorola Stylus 5G, set manual DNS (Cloudflare / Google), and cleared app cache for Nextcloud.  
- Verified Nextcloud and Google Drive accessibility on both devices.

---

## Windows (HP Laptop) — Driver and Network Repair

### 1. Confirm the Symptom
- Wi-Fi networks not showing in the taskbar, or connection attempts fail.
- In **Device Manager**: generic entries like **Network Controller**, **PCI Device**, or devices with a yellow exclamation mark under **Network adapters**.

**Quick checks:**
- `Win + X` → Device Manager  
- `ping 1.1.1.1` (to test raw IP connectivity — usually fails if no driver)

---

### 2. Prepare Driver Sources (off-machine if necessary)
If the laptop has no internet:

1. From another computer with internet, go to:  
   `https://support.hp.com/drivers`
2. Enter the laptop model or serial number.  
3. Choose **Windows 11 (64-bit)** as the OS.  
4. Download required driver installers (recommended order):
   - Chipset / Platform driver (install first)
   - Intel/Realtek Wi-Fi driver (e.g., Intel AX201)
   - Ethernet driver (Realtek / Intel)
   - Bluetooth driver
5. Copy the `.exe` or driver packages to a USB drive for transfer.

---

### 3. Install Drivers on the Laptop (Order matters)
1. Run **Chipset** installer → reboot if prompted.  
2. Run **Wi-Fi** installer → reboot.  
3. Run **Ethernet** installer → reboot.  
4. Run **Bluetooth** installer → reboot.  

After each install:
- Open **Device Manager** and confirm the device now shows a proper name (e.g., `Intel(R) Wi-Fi 6 AX201`), not “Network Controller”.
- Check driver versions match HP’s website.

---

### 4. Verify Windows Network Functionality
Open an elevated command prompt (Admin) and run:

```cmd
ipconfig /all
ping 1.1.1.1
ping google.com
```

---

### 5. Reset Windows Network Stack (if residual issues)
If installs completed but network behavior is not working as expected, reset the stack

Open an elevated command prompt (Admin) and run:
```cmd
netsh winsock reset
netsh int ip reset
ipconfig /release
ipconfig /renew
ipconfig /flushdns
```
Reboot the laptop and re-rest connectivity

---

### 6. Motorola Stylus 5G - DNS & Network reset
- Symptom: Wi-Fi connected but apps/browsers report "Host not found" and Nextcloud fails to sync. Other devices on the same Wi-Fi work as expected

1. Quick Diagnostics on the phone
	- Toggle Wi-Fi off/on
	- Open a browser and try https://google.com
	- If DNS lookup errors persist, proceed with the reset below
	
2. Soft Reset
	- Toggle Airplane mode ON -> OFF. This will drop and re-request DHCP and DNS from the router.
	- If still failing, reboot the phone
If that fixes it, the issue was a transient DHCP/DNS binding - monitor for recurrence

3. Network reset (if soft reset fails)
This removes saved Wi-Fi networks and clears network settings - it's fast and often resolves corrupt resolver state

	- Open Settings -> System -> Advanced -> Reset options.
	- Tap Reset Wi-Fi, mobile & Bluetooth
	- Confirm Reset settings. Reboot phone
	
After reboot: reconnect to Wi-Fi and test again

The network reset solved the client's issues with her phone.