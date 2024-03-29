# Ironman-uBlue LEGACY BUILD

> **Warning**
> ***THIS BUILD HAS BEEN ARCHIVED AND IS NOW CONSIDERED LEGACY AS WE FORK AND START USING UBLUE-OS/BLUEFIN AS A BASE***

A familiar(ish) Ubuntu desktop for Fedora Silverblue "forked" from ublue-os/ubuntu and edited for my primary use cases.
Currently you'll need to have Fedora Silverblue installed to rebase to this image (see below). We will provide ISOs as soon as the custom image feature lands in the Fedora installer.

This is an interpretation of "What if we could rebuild Ubuntu from the ground up built on cloud-native technology?"
The goal is to provide an Ubuntu experience using the most amount of automation possible.
The endstate is a system as reliable as a Chromebook with near-zero maintainance, but with the power of Ubuntu and Fedora fused together.

> "Let's see what's out there." - Jean-Luc Picard

## Usage

> **Warning**
> This is an experimental feature and should not be used in production, try it in a VM for a while! If you are rebasing and not doing a clean install do a `touch ~/.config/ublue/firstboot-done` to keep your flatpak configuration untouched, otherwise we're going to mangle it (for science).

1.  Download and install [Fedora Silverblue](https://silverblue.fedoraproject.org/download)
1.  After you reboot you should [pin the working deployment](https://docs.fedoraproject.org/en-US/fedora-silverblue/faq/#_about_using_silverblue) so you can safely rollback.
1.  Open a terminal and rebase the OS to this image:

        sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/ironman820/ironman-ublue:latest

1.  Reboot the system and you're done!

1.  To revert back:

        sudo rpm-ostree rebase fedora:fedora/37/x86_64/silverblue

Check the [Silverblue documentation](https://docs.fedoraproject.org/en-US/fedora-silverblue/) for instructions on how to use rpm-ostree.

The `latest` tag will automatically point to the latest build.

## Features

**This image heavily utilizes _cloud-native concepts_.**

System updates are image-based and automatic. Applications are logically seperated from the system by using Flatpaks, and the CLI experience is contained within OCI containers:

- Ubuntu-like GNOME layout
  - Includes the following GNOME Extensions
    - Appindicator - for tray-like icons in the top right corner
    - GNOME Variable Refresh Rate patches included via the [GNOME VRR COPR](https://copr.fedorainfracloud.org/coprs/kylegospo/gnome-vrr/)
    - Blur my Shell - for dat bling
- GNOME Software with Flathub
  - Use a familiar software center UI to install graphical software
- Built-in Ubuntu user space
  - Official Ubuntu LTS cloud image
    - `Ctrl`-`Alt`-`u` - will launch an Ubuntu image inside a terminal via [Distrobox](https://github.com/89luca89/distrobox), your home directory will be transparently mounted
    - A [BlackBox terminal](https://www.omgubuntu.co.uk/2022/07/blackbox-gtk4-terminal-emulator-for-gnome) is used just for this configuration
    - Use this container for your typical CLI needs or to install software that is not available via Flatpak or Fedora
    - Refer to the [Distrobox documentation](https://distrobox.privatedns.org/#distrobox) for more information on using and configuring custom images
  - GNOME Terminal
    - `Ctrl`-`Alt`-`t` - will launch a host-level GNOME Terminal if you need to do host-level things in Fedora (you shouldn't need to do much).
- Cloud Native Tools
  - [kind](https://kind.sigs.k8s.io/) - Run a Kubernetes cluster on your machine. Do a `kind create cluster` on the host to get started!
  - [kubectl](https://kubernetes.io/docs/reference/kubectl/) - Administer Kubernetes Clusters
  - [Podman-Docker](https://github.com/containers/podman) - Automatically aliases the `docker` command to `podman`
  - [virt-manager](https://virt-manager.org/) - for virtual machine management
- Quality of Life Improvements
  - [webapp-manager](https://github.com/linuxmint/webapp-manager) for Progressive Web App (PWA) management
    - Uses the included Firefox, no other browser download needed
    - Thanks to Linux Mint for a great tool!
  - systemd shutdown timers adjusted to 15 seconds
  - udev rules for game controllers included out of the box
  - [Tailscale](https://tailscale.com/) for VPN
  - [Just](https://github.com/casey/just) task runner for post-install automation tasks
  - [input-remapper](https://github.com/sezanzeb/input-remapper) for remapping input devices
- Built on top of the the [uBlue main image](https://github.com/ublue-os/main)
  - System designed for automatic staging of updates
    - If you've never used an image-based Linux before just use your computer normally
    - Don't overthink it, just shut your computer off when you're not using it

### Future Features

These are currently unimplemented ideas that we plan on adding:

- Provide a `:lts` tag derived from CentOS Stream for a more enterprise-like cadence
- [Firecracker](https://github.com/firecracker-microvm/firecracker) - help wanted with this!
- Inclusion of more Ubuntu artwork

### Applications

- Mozilla Firefox, Mozilla Thunderbird, Extension Manager, Libreoffice, FontDownloader, Flatseal, ObsidianMD, Birdtray, Blender, Gimp, OBS Studio, Barrier, Bottles, Edge, Chrome, Teams, Putty, Wireshark, Zotero, Yubico Authenticator, Zoom, Calibre, and the VLC Media Player
- Core GNOME Applications installed from Flathub
  - GNOME Calculator, Calendar, Characters, Connections, Contacts, Evince, Firmware, Logs, Maps, NautilusPreviewer, TextEditor, Weather, baobab, clocks, eog, and font-viewer
- All applications installed per user instead of system wide, similar to openSUSE MicroOS. Thanks for the inspiration Team Green!

## Verification

These images are signed with sisgstore's [cosign](https://docs.sigstore.dev/cosign/overview/). You can verify the signature by downloading the `cosign.pub` key from this repo and running the following command:

    cosign verify --key cosign.pub ghcr.io/ironman820/ironman-ublue

## Frequently Asked Questions

What about codecs?

> It's unlikely you'll need extra codecs, Flathub provides everything you need. You might need to [force enable hardware acceleration](https://fedoraproject.org/wiki/Firefox_Hardware_acceleration#Web_page_rendering) in Firefox directly.

I cancelled the first run thing or it failed, how do I rerun it?

> Running `/usr/bin/ublue-firstboot` will restart the process. You might need to delete `~/.config/ublue/firstboot-done` if you ever want to rerun it again.

How do I get my GNOME back to normal Fedora defaults?

> We set the default dconf keys in `/etc/dconf/db/local`, removing those keys and updating the database will take you back to the fedora default:

    sudo rm -f /etc/dconf/db/local
    sudo dconf update
