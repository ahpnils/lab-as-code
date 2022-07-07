variable "images_pool" {
  default = "default"
}

variable "boot_pool" {
  default = "default"
}

variable "fedora_image_source" {
  default = "https://ftp.lip6.fr/ftp/pub/linux/distributions/fedora/releases/36/Cloud/x86_64/images/Fedora-Cloud-Base-36-1.5.x86_64.qcow2"
}

variable "vyos_image_source" {
  default = "https://medias.anotherhomepage.org/vm/vyos-1.4-rolling-202203110317-cloud-init-10G-qemu.qcow2"
}

variable "libvirt_uri" {
  default = "qemu:///system"
}


