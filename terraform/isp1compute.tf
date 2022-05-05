resource "libvirt_volume" "isp1vps1_vol" {
  name = "isp1vps1.qcow2"
  pool = "nils_images"
  base_volume_id = libvirt_volume.fedora_image.id
}

resource "libvirt_volume" "isp1router1_vol" {
  name = "isp1router1.qcow2"
  pool = "nils_images"
  base_volume_id = libvirt_volume.vyos_image.id
}

resource "libvirt_cloudinit_disk" "commoninit" {
  #name = "${var.hostname}-commoninit.iso"
  name = "isp1router1-commoninit.iso"
  pool = "nils_boot"
  meta_data = data.template_file.isp1router1_metadata.rendered
  user_data = data.template_file.isp1router1_userdata.rendered
}

data "template_file" "isp1router1_metadata" {
  template = file("../cloud-init/isp1router1/meta-data")
}

data "template_file" "isp1router1_userdata" {
  template = file("../cloud-init/isp1router1/user-data")
}

resource "libvirt_domain" "isp1router1" {
  name = "isp1router1"
  memory = "512"
  vcpu = "1"
  #metadata = data.template_file.isp1router1_metadata.rendered
  #user_data = data.template_file.user_data.rendered
  cloudinit = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    network_name = "default"
  }

  network_interface {
    network_name = "isp1net1"
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

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }

  disk {
    volume_id = libvirt_volume.isp1router1_vol.id
  }

}

resource "libvirt_domain" "isp1vps1" {
  name = "isp1vps1"
  memory = "1024"
  vcpu = "2"
  
  network_interface {
    network_name = "isp1net1"
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

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }

  disk {
    volume_id = libvirt_volume.isp1vps1_vol.id
  }

}
