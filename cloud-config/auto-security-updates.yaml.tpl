#cloud-config

apt:
  disable_suites:  
    - backports
    - proposed

packages:
  - unattended-upgrades

write_files:
  - path: /etc/apt/apt.conf.d/20auto-upgrade
    permissions: '0644'
    content: |
      APT::Periodic::Update-Package-Lists "1";
      APT::Periodic::Download-Upgradeable-Packages "1";
      APT::Periodic::AutocleanInterval "7";
      APT::Periodic::Unattended-Upgrade "1";

  - path: /etc/apt/apt.conf.d/50unattended-upgrades
    permissions: '0644'
    content: |
      Unattended-Upgrade::Allowed-Origins {
      //  "${distro_id}:${distro_codename}";
      //  "${distro_id}:${distro_codename}-updates";
          "${distro_id}:${distro_codename}-security";
      };

      Unattended-Upgrade::Remove-Unused-Dependencies "false";
      Unattended-Upgrade::Automatic-Reboot "false";
      Unattended-Upgrade::Automatic-Reboot-Time "+${restart_window}";

