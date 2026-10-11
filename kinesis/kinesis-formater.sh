#!/bin/sh
# Reformate le v-Drive 2 Mo du Kinesis Advantage2 comme le fait la procédure Kinesis
# (FAT, clusters de 512 octets, nom KINESIS KB). Le clavier régénère ensuite ses fichiers.
set -e

D=$(readlink -f /dev/disk/by-id/usb-ATMEL_AT45DBX_Data_Fla_314159265359-0:0)

[ "$(id -u)" = 0 ] || { echo "À lancer avec sudo"; exit 1; }
[ -b "$D" ] || { echo "v-Drive introuvable : ouvre-le avec progm + F1"; exit 1; }

if grep -q "^$D " /proc/mounts; then
  umount "$D" || { echo "Volume occupé : ferme la fenêtre Nautilus sur KINESIS KB"; exit 1; }
fi

mkfs.vfat -I -F 12 -s 1 -R 8 -r 512 -g 1/1 -n "KINESIS KB" "$D"
sync
fsck.vfat -n "$D"
echo "OK : v-Drive formaté"
