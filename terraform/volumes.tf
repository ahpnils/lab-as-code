resource "libvirt_volume" "fedora_image" {
  name = "fedora_image.qcow2"
  source = "/home/nils/libvirt/boot/Fedora-Cloud-Base-36-1.5.x86_64.qcow2"
  #source = "https://ftp.lip6.fr/ftp/pub/linux/distributions/fedora/releases/36/Cloud/x86_64/images/Fedora-Cloud-Base-36-1.5.x86_64.qcow2"
  pool = "nils_images"
}

resource "libvirt_volume" "vyos_image" {
  name = "vyos_image.qcow2"
  source = "/home/nils/libvirt/boot/vyos-1.4-rolling-202203110317-cloud-init-10G-qemu.qcow2"
  pool = "nils_images"
}
