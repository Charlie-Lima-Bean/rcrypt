# Regarded tpm2-based auto unlocking scheme for redundant boot drive arrays because btrfs is not happy unless it can see everything
Use at your own risk. Scripts have no safeguards against accidental damage. I could spend time fixing these, but it's probably more efficient to wait until systmd-cryptenroll starts to actually work with tpm2.

# What does this do?
Seals keys against tpm2 regisers, which are used to decrypt drives prior to mounting your root fs

# Why are we here?
- tl;dr proxmox raid boot, systemd-cryptenroll and clevis don't quite work
- You are on proxmox and would like to leverage proxmox-boot-tool, which does not play nice with dracut
- systemd-cryptenroll doesn't work for some reason
    - crypttab is _only_ imported to initramfs if the rootfs is in there.
        - if you're using btrfs and swapping your original drives for encrypted volumwa, this is a complication
            - "rootfs" is not actually encrypted
            - crypttab not imported to initramfs
            - btrfs sees missing device, and fails initial mount
        - this can be bypassed by adding a hook to initramfs-tools to manually copy the crypttab in
    - On bookworm stable, tpm2-device=auto as a crypttab option is not recognized by the initramfs hook
        - this fix can be backported manually
    - Having got this far, systemd-cryptsetup consistently gets a tpm2 read error at the initramfs stage, resulting in a passky prompt.
        - crypttab with tpm2-device=auto works fine _after_ kernel load though.
- clevis-luks-bind also doesn't work
    - it generally was not happy after multiple binds, which is should actually support.

# "threat model"
- The usual tpm caveats. This is fundamentally less secure than prompting for passkeys, but lazier.
- Secureboot will complicate things if your primary boot drive fails, and you need to boot off of a backup drive's bootloader. Could explore duping bootloader partition UUIDs, since pausing it will shuffle PCR 7


# Usage - all requires sudo - the only proxmox default user is root anyways (: 
Boot Drive procedure:
1) prereqs
2) gen-key <keyname>
- Generates a random key and seals it against the tpm2
- `./gen-key.sh keyname`
3) init-boot <src> <dest>
- Clones the partitions of src to dest, and adds dest2 to the proxmox-boot-tool
- This is based on the default proxmox partitioning
- ie, you shose sda in the proxmox installer, and would like to add sdb
- If proxomox-boot-tool complains about filesystem type, just run this again.
- `./init-boot.sh /dev/sda /dev/sdb`
4) init-crypt-root <device to encrypt> <name of volume when mounted> <keyname to use>
- Overwrites the partition 3 with a luks volume
- Will prompt for a passkey first. This is a fallback if auto mounting fails.
- Will automatically add keyname second
- Will mount new luks volume and add it to btrfs root filesystem
- `./init-crypt-root.sh /dev/sdb luksvolname keyname`
5) push-initramfs.sh
- pushes required hooks / scripts to initramfs-tools
- pushes rtab and keyhashes to initramfs-tools
- `./push-initramfs.sh`

Data Drive procedure:
1) init-crypt-data
 - same as root above, but adds it to /mnt/data's btrfs filesystem above
 - does not update rtab, so this drive won't be mounted pre-kernel launch
 - does update crypttab, so this drive should automount once the kernel is launched
 - `./init-crypt-data /dev/sdc cryptname keyname`

 Recovery procedures:
 - If grub
    - exit and boot off a different drive, figuring out which partition to mount is a lot of work
    - `cryptomount (hdx,gptx)`
    - `insmod normal` `normal`
 - If dropped to initramfs
    - if you have enough mounted os drives
        - `mount /dev/sda root -t btrfs -o degrade,rw`
    - `/rcrypt/bin/rcrypt-automount.sh` -> attempt to re-run rtab.conf
    - `/rcrypt/bin/rcrypt-mount.sh` -> spam a passkey at everything in rtab.conf
 - If booted
    - `./initramfs-util/rcrypt-automount.sh /etc`
    - `./initramfs-util/rcrypt-mount.sh /etc`
    - inspect your drives with the rest of the utils available

TODO, likely never, since this is just a drop-in until systemd-cryptenroll works as expected
- Make the PCRs configurable. Editting the script is fine ofc
