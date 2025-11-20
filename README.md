# 🐧 Linux Sysadmin Toolkit

A collection of automation scripts for Linux system administration. Built as part of my home lab to demonstrate core sysadmin competencies.

## 🔧 Features
- Automated user & group management  
- Backup directory rotation  
- Log file cleanup  
- Permission auditing  

## 📂 Scripts Included
| Script | Purpose |
|--------|---------|
| user_mgmt.sh | Create, delete, and modify users |
| backup_rotation.sh | Maintain rotating backup sets |
| log_cleanup.sh | Purge logs based on age |
| permissions_audit.sh | Report file/folder permission issues |

## 🚀 How to Use
```bash
chmod +x scripts/*.sh
sudo ./scripts/user_mgmt.sh
