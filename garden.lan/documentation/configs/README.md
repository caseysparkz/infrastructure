# Configuration Backups
This directory contains backup configurations for all network devices on the garden.lan local area network (LAN).

## Table of Contents
* [Encryption](#Encryption)
* [File Naming Convention](#File-Naming-Convention)

## Encryption
Given that each backup configuration may contain secrets (such as passwords, certificates, and private keys),
all backups should be signed by, and encrypted to, `0x2027DEDFECE6A3D5`.

## File Naming Convention
Each configuration is named according to the following underscore-deliniated convention:
1. Two-character device indicator.
    - ap: access point
    - fw: firewall
    - ro: router
    - sw: switch
2. Hostname.
3. Unix timestamp of backup date.
4. Original file extension (like `.conf`).
5. '.gpg' extension.

Therefore, `fw_helix_1692813120.xml.gpg` references an XML firewall configuration with hostname 'helix',
created on August 23, 2023 at 10:52:00AM.

To encrypt a cleartext backup:

```
gpg                                                                                 \
    --sign                                                                          \
    --encrypt                                                                       \
    --recipient 0x2027DEDFECE6A3D5                                                  \
    --output <HARDWARE_CODE>_<HOSTNAME>_$(date +%s).<ORIGINAL_EXTENSION>.gpg        \
    <INPUT_FILE>
```
