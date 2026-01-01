
# ZarProject is an Admin Theme for Pterodactyl

![Project Status](https://img.shields.io/badge/status-active-success)
![Version](https://img.shields.io/badge/version-1.1-blue)
![License](https://img.shields.io/badge/license-MIT-green)

**ZarProject** is a futuristic and high-performance UI overhaul specifically designed for the Pterodactyl **Administration Panel**. It replaces the default look with a stunning glassmorphism design, animated grid backgrounds, and real-time monitoring capabilities.

---

## ✨ Key Features

### ⚙️ Admin Dashboard Overhaul
- **Real-Time Monitoring**: Implemented **AJAX Polling** to auto-update system stats (CPU, RAM, Disk, User Count) every **2 seconds** without refreshing the page.
- **Glassmorphism UI**: Translucent cards with subtle borders, glowing effects, and a modern dark aesthetic.
- **Grid Background**: An animated, seamless grid pattern that gives a depth of field to the dashboard.
- **Modern Typography & Icons**:
  - Replaced legacy FontAwesome icons with **Google Material Icons Outlined** for a sharper, cleaner look.
  - Optimized font colors for high readability in dark mode.
- **Dynamic Progress Bars**: Resource usage bars now feature gradient fills (Indigo/Purple/Green) based on load levels.

---

## 🖼️ Preview

| Admin Dashboard | Resource Monitor |
|:---:|:---:|
| ![Admin Dashboard](https://files.cloudkuimages.guru/images/2a0b53cdcc6a.jpg) | ![Resource Monitor](https://files.cloudkuimages.guru/images/fa066f6d0c18.jpg) |

---

## 📦 Installation

Installation is fully automated. Simply run the following command on your Pterodactyl server:

```bash
bash <(curl -s [https://raw.githubusercontent.com/ZarOffc11/admin-theme/main/install.sh](https://raw.githubusercontent.com/ZarOffc11/admin-theme/main/install.sh))
```

This script will automatically backup your old views and apply the Nebula Grid theme to your Admin Panel.

---

### 📋 Changelog
# [1.1] - 2026-01-01 :
## ➕ Added
 * Admin Overview Revamp:
   * Full redesign of admin/index.blade.php.
   * Added Auto-Refresh mechanism for statistics cards.
   * Integration of Material Icons CDN.
   * Added gradient indicators for "System Health" status.
## 🛠 Fixed
 * Server Creation Bug: Fixed an issue where the server creation modal would not trigger correctly in the previous build.
# [1.0] - 2025-12-31
 * 🎉 Initial Release:
   * Launch of the ZarProject Admin Theme.
   * Core grid styling and dark mode variables implementation.
  
---

### 📝 Credits
 * Base Software: Pterodactyl Panel
 * Theme Developer: ZarProject

© 2015 - 2026 ZarProject. All rights reserved.
