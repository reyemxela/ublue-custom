#!/bin/bash

set -ouex pipefail

systemctl enable sshd.service
systemctl enable tailscaled.service
systemctl enable libvirtd.service 2>/dev/null || true

# let bazzite-deck continue to use its tweaked update system,
# everything else use rpm-ostreed-automatic/flatpak-system-update
if [[ $FULL_IMAGE_NAME = 'bazzite-deck' ]]; then
  systemctl disable flatpak-system-update.timer
else
  sed -i 's/AutomaticUpdatePolicy=.*/AutomaticUpdatePolicy=stage/' /etc/rpm-ostreed.conf
  systemctl disable ublue-update.timer 2>/dev/null || true
  systemctl enable rpm-ostreed-automatic.timer
  systemctl enable flatpak-system-update.timer
fi

if [[ -e /usr/bin/sunshine ]]; then
  systemctl enable sunshine-workaround.service
fi

if [[ -e /usr/bin/dumpcap ]]; then
  systemctl enable wireshark-workaround.service
fi

sed -i 's@SHELL=.*@SHELL=/usr/bin/zsh@' /etc/default/useradd