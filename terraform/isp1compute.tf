resource "libvirt_volume" "isp1vps1_vol" {
  name = "isp1vps1.qcow2"
  pool = "nils_images"
  base_volume_id = libvirt_volume.fedora_image.id
}

resource "libvirt_domain" "isp1vps1" {
  name = "isp1vps1"
  memory = "1024"
  vcpu = "2"
  
  network_interface {
    network_name = "default"
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = libvirt_volume.isp1vps1_vol.id
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}
