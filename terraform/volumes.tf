resource "libvirt_volume" "fedora_image" {
  name = "fedora_image.qcow2"
  source = "/home/nils/libvirt/boot/Fedora-Cloud-Base-36_Beta-1.4.x86_64.qcow2"
  #source = "https://ftp.lip6.fr/ftp/pub/linux/distributions/fedora/releases/test/36_Beta/Cloud/x86_64/images/Fedora-Cloud-Base-36_Beta-1.4.x86_64.qcow2"
  pool = "nils_images"
}
