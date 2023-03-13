
ARG FEDORA_MAJOR_VERSION=37

FROM ghcr.io/ublue-os/silverblue-main:${FEDORA_MAJOR_VERSION}

COPY etc /etc
COPY usr /usr

COPY --from=ghcr.io/ublue-os/config:latest /files/ublue-os-udev-rules /
COPY --from=ghcr.io/ublue-os/config:latest /files/ublue-os-update-services /
COPY --from=docker.io/mikefarah/yq /usr/bin/yq /usr/bin/yq

COPY ublue-firstboot /usr/bin
COPY recipe.yml /etc/ublue-recipe.yml

RUN rpm-ostree remove gnome-tour gnome-extensions
RUN rpm-ostree install dnf-plugins-core
RUN wget https://github.com/terrapkg/subatomic-repos/raw/main/terra.repo -O /etc/yum.repos.d/terra.repo
RUN wget https://copr.fedorainfracloud.org/coprs/kylegospo/gnome-vrr/repo/fedora-$(rpm -E %fedora)/kylegospo-gnome-vrr-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_kylegospo-gnome-vrr.repo
RUN wget https://copr.fedorainfracloud.org/coprs/sunwire/input-remapper/repo/fedora-37/sunwire-input-remapper-fedora-37.repo -O /etc/yum.repos.d/sunwire-input-remapper-fedora-37.repo
RUN wget https://copr.fedorainfracloud.org/coprs/kylegospo/webapp-manager/repo/fedora-37/kylegospo-webapp-manager-fedora-37.repo -O /etc/yum.repos.d/kylegospo-webapp-manager-fedora-37.repo
RUN wget https://download.docker.com/linux/fedora/docker-ce.repo -O /etc/yum.repos.d/docker-ce.repo
RUN rpm-ostree override replace --experimental --from repo=copr:copr.fedorainfracloud.org:kylegospo:gnome-vrr mutter gnome-control-center gnome-control-center-filesystem
RUN rpm-ostree override remove gnome-software-rpm-ostree firefox firefox-langpacks
RUN rpm-ostree install blackbox-terminal gnome-shell-extension-appindicator \
    gnome-shell-extension-blur-my-shell gnome-shell-extension-sound-output-device-chooser \
    gnome-shell-extension-screenshot-resizer gnome-shell-extension-no-overview \
    gnome-shell-extension-caffiene gnome-shell-extension-gpaste \
    gnome-shell-extension-just-perfection \
    # libgda libgda-sqlite libratbag-ratbagd openssl podman-docker python3-input-remapper \
    libgda libgda-sqlite libratbag-ratbagd openssl python3-input-remapper \
    webapp-manager yaru-theme gnome-tweaks pam-u2f pamu2fcfg \
    python3 python3-pip syncthing \
    docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin && \
    rm -f /var/lib/unbound/root.key && \
    rm -f /var/lib/freeipmi/ipckey && \
    systemctl unmask dconf-update.service && \
    systemctl enable dconf-update.service && \
    systemctl enable rpm-ostree-countme.service && \
    systemctl enable docker && \
    fc-cache -f /usr/share/fonts/ubuntu && \
    rm -rf /usr/share/gnome-shell/extensions/background-logo@fedorahosted.org && \
    rm -f /etc/yum.repos.d/terra.repo && \
    rm -f /etc/yum.repos.d/_copr_kylegospo-gnome-vrr.repo && \
    rm -f /etc/yum.repos.d/sunwire-input-remapper-fedora-37.repo && \
    rm -f /etc/yum.repos.d/kylegospo-webapp-manager-fedora-37.repo && \
    sed -i 's/#DefaultTimeoutStopSec.*/DefaultTimeoutStopSec=15s/' /etc/systemd/user.conf && \
    sed -i 's/#DefaultTimeoutStopSec.*/DefaultTimeoutStopSec=15s/' /etc/systemd/system.conf && \
    authselect enable-feature pam-with-u2f && \
    rpm-ostree cleanup -m && \
    ostree container commit
