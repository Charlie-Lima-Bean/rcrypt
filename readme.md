# Regarded tpm2-based auto unlocking scheme for redundant boot drive arrays because btrfs is not happy unless it can see everything
Use at your own risk. Scripts have no safeguards against accidental damage. I could spend time fixing these, but it's probably more efficient to wait until systmd-cryptenroll starts to actually work with tpm2.

# What does this do?
Seals keys against tpm2 regisers, which are used to decrypt drives prior to mounting your root fs

# Why are we here?
- You are on proxmox and would like to leverage proxmox-boot-tool, which does not play nice with dracut
- systemd-cryptenroll
    - crypttab is _only_ imported to initramfs if the rootfs is in there.
        - if you're using btrfs and swapping your original drives for encrypted volumwa, this is a complication
            - "rootfs" is not actually encrypted
            - crypttab not imported to initramfs
            - btrfs sees missing device, and fails initial mount
        - this can be bypassed by adding a hook to initramfs-tools to manually copy the crypttab in
    - On bookworm stable, tpm2-device=auto as a crypttab option is not recognized by the initramfs hook
        - this fix can be backported manually
    - Having got this far, systemd-cryptsetup consistently gets in a tpm2 read error at the initramfs stage, resulting in a passky prompt.
        - crypttab with tpm2-device=auto works fine _after_ kernel load though.
- clevis-luks-bind
    - is not happy if you bind multiple drives. seems odd, idk.

# Usage - all requires sudo - the only proxmox default user is root anyways (: 
Boot Drive procedure:
1) prereqs
2) gen-key <keyname>
- Generates a random key and seals it against the tpm2
    - @TODO make the registers configurable. For now, just edit the script
- `./gen-key.sh keyname`
3) init-boot <src> <dest>
- Clones the partitions of src to dest, and adds dest2 to the proxmox-boot-tool
- This is based on the default proxmox partitioning
- ie, you shose sda in the proxmox installer, and would like to add sdb
- `./init-boot.sh /dev/sda /dev/sdb`
4) init-crypt-root <PARTITION to encrypt> <name of volume when mounted> <keyname to use>
- Overwrites the given partition with a luks volume
- Will prompt for a passkey first. This is a fallback if auto mounting fails.
- Will automatically add keyname second
- Will mount new luks volume and add it to btrfs root filesystem
- `./init-crypt-root.sh /dev/sdb3 luksvolname keyname`
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