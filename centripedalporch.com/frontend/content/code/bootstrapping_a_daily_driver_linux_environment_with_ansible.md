---
title: 'Bootstrapping a Daily Driver Linux Environment with Ansible'
date: '2023-10-03'
draft: false
language: 'en'
summary: 'Leveraging Ansible to build secure end-user Linux systems and support my distro-hopping habit.'
featured_image: '../assets/images/posts/code/bootstrapping_a_daily_driver_linux_environment_with_ansible.png'
categories: 'code'
tags: 
    - 'curations'
    - 'code'

---
[**Github Repository**](https://github.com/caseysparkz/env)

I've been using Linux as my daily driver since 2019.

Every seasoned Linux user has done their fair share of distro-hopping, switching between distributions with the
hope of finding (or building) their perfect operating system. For me, that distribution was Arch (btw) but I
spent three years hopping between Ubuntu, Debian, Fedora, and Manjaro before settling.

Initially, I laboriously and manually configured each new system, each time telling myself each time that this was
the last time I'd have to do this.

Discovering `make` was a godsend. I could create application-specific targets, and install my aliases, shell
scripts, and configurations with a single command. However, as my environment ballooned due to further
customization, my desire to automate grew beyond the capabilities of a single Makefile.

I'd already used Ansible to orchestrate on-premise servers at work, so building a playbook was the natural next
step in bootstrapping a new machine into a daily driver.

---

The playbook aims to:
* Harden Linux.
* Optimize system performance.
* Installing some useful packages.
* Set up an environment that I like.

All while remaining portable between RHEL-, Debian-, and Arch-based systems.

To achieve this, the playbook consists of four roles. Respectively:
* `security`
* `performance_tweaks`
* `packages`
* `environment`

---
## Playbook Roles
### Security
This playbook makes **significant** changes to kernel, grub, sysctl, filesystem modes, system services, based on
the [Center for Internet Security's Linux Benchmarks](https://www.cisecurity.org/benchmark). Not all benchmarks
are implemented, though parity remains the end-goal.

The playbook also disables system crash reporters and enables unattended upgrades for _security packages only_.


### Performance Tweaks
Presently the smallest role. Enables the fstrim timer, IO schedulers, some other stuff. RTFM.


### Packages
Self-explanatory. It installs software I require.


### Environment
The largest role in this playbook, and the least relevant for people who are not me.
This role sets up my preferred user environments and dotfiles for Bash, Git, GnuPG, Gnu Screen, SSH, Vim, etc.
It modifies the `$PATH` environment variable to include my personal scripts directories, installs my own CA
chains, and removes Snap on Ubuntu systems.

---
