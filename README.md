# LTSC Essentials
LTSC Essentials is a PowerShell-based utility for installing core apps on Windows 10/11 LTSC.

---

## 💡 Prerequisites

* Windows 10 or 11 LTSC
* Admin privileges

---

#### Start Menu Method

1. Right-click on the **Start Menu**.
2. Select **Windows PowerShell (Admin)** (Windows 10) or **Terminal (Admin)** (Windows 11).
3. Accept the UAC prompt.

#### Search and Launch Method

1. Press the **Windows key**.
2. Type **PowerShell** (Windows 10) or **Terminal** (Windows 11).
3. Press **Ctrl + Shift + Enter**, or right-click and select **Run as administrator**.
4. Accept the UAC prompt.

---

### Run Winutil

```powershell
irm "https://raw.githubusercontent.com/eun0115/win-ltsc-essentials/refs/heads/main/install.ps1" | iex
```

---

## 🛠 Features

* Installs essential apps for Windows LTSC
* Adds Windows 11 extras if detected
* Handles dependencies like .NET Native frameworks
* Stores temporary files in `%TEMP%` during execution
* Installs apps using `Add-AppxPackage` and MSIX bundles

---

## 📄 License

MIT License
