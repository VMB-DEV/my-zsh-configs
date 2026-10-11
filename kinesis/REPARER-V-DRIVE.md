# Réparer le v-Drive du Kinesis Advantage2

Ce qui a fonctionné le 11/10/2026 (dossier `active` illisible).

1. Ouvrir le v-Drive : `progm` + `Shift` + `Esc`, puis `progm` + `F1`.
2. Fermer Nautilus, puis formater :

   ```sh
   sudo sh ~/kinesis-recovered/kinesis-formater.sh
   ```

3. Débrancher puis rebrancher le clavier.
4. Dans l'ordre : `progm` + `F5`, `progm` + `F7`, `progm` + `F4`, `progm` + `F5`, `progm` + `F7`,
   `progm` + `F3`.
5. Rouvrir le v-Drive (`progm` + `F1`) et remettre le layout :

   ```sh
   cp ~/kinesis-recovered/qwerty-sauvegarde.txt "/media/vkdev/KINESIS KB/active/qwerty.txt"
   ```

6. Éjecter `KINESIS KB` dans Nautilus, puis `progm` + `F1`.

## Le script

`kinesis-formater.sh` :

```sh
#!/bin/sh
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
```
