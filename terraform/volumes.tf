resource "libvirt_volume" "fedora_image" {
  name = "fedora_image.qcow2"
  source = var.fedora_image_source
}

resource "libvirt_volume" "vyos_image" {
  name = "vyos_image.qcow2"
  source = var.vyos_image_source
}
