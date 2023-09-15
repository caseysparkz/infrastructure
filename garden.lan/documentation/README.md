# Documentation
## Table of Contents
* [Configuration Backups](./configs/README.md#Configuration-Backups)
* [Hardware](./hardware/README.md#Hardware)
* [Network](#Network)
    * [Topology](#Topology)
    * [Services](#Services)

## Configuration Backups
Refer to [./configs/README.md#Configuration-Backups](./configs/README.md#Configuration-Backups)

## [Hardware](./hardware/README.md#Hardware)
Refer to [./hardware/README.md#Hardware](./hardware/README.md#Hardware)

## Network
### Topology
| VLAN  | Name          | Subnet             |
| ----: | :------------ | :----------------- |
|     1 | Default       | 192.168.1.0    /24 |
|     5 | IoT           | 192.168.5.0    /24 |
|    10 | Servers       | 192.168.10.0   /24 |
|   100 | Trusted       | 192.168.100.0  /24 |
|   101 | Guest         | 192.168.101.0  /24 |
|  4000 | Management    | 172.016.010.0  /24 |

### Services
| Service       | Host          | Port  |
| :------------ | :------------ | ----: |
| DNS           | 172.16.10.1   |    53 |
| NTP           | 172.16.10.1   |   123 |
