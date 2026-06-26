---
icon: lucide/rocket
---

# Welcome

Like a VM for you, but in a container.


This project focus on providing a simple OpenSSH server. Then, you can customize your new home.

## Features

* Data Persistance:
    * Home data are preserved
* SSH configuration:
    * SSH hosts keys persistance
    * Automatically provision user SSH key, with URL support, to load your github keys
    * Provide custom SSH port, when using with host network mode (TODO)
* Customizable package installation
    * During runtime or at build time
* Support init scripts and custom services
    * Provide strong foundations for init and daemon scripts, with mount points instead of image rebuilds.
* Make your own
    * Use this image as base image, and extend functionalities
* User and permission management
    * Be able to use any username, uid or gid settings
    * Optional sudo support
* Default tooling:
    * Provide optional docker socket to control host
    * Provide mise tool
    * Provide oh-my-bash
* Provide defaults packages for development and troubleshooting
    * git, htop, iftop
* Slim image
    * Do not install recommended packages
    * Does not install documentation or man pages
    * Only provide en_US locale
* Custom scripts container
    * Develop on one container, push script on a second container with the same enviroment and tooling to gain velocity. Then make your own image for production, or keep it like it as a glue script environment.
    * Easily customisable 

## Use cases

* Use as sidecar system for truenas server. While truenas is an appliance, it's designed to have a read-only file system. You can now install your favorite tools, and browse your nas file with a convenient environment.
* Turnkey home environment. You can deploy use this image to deploy your $HOME almost anywhere
* Use this image to deploy your own scripts. Since it provide a general usage container, push your scripts, and call them from external system like n8n.
* Use this image to be able to make tests on production server without being afraid to change anything on the host.
