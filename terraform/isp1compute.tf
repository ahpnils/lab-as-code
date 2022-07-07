resource "libvirt_volume" "isp1vps1_vol" {
  name = "isp1vps1.qcow2"
  pool = var.images_pool
  base_volume_id = libvirt_volume.fedora_image.id
}

resource "libvirt_volume" "isp1dns1_vol" {
  name = "isp1dns1.qcow2"
  pool = var.images_pool
  base_volume_id = libvirt_volume.fedora_image.id
}

resource "libvirt_volume" "isp1router1_vol" {
  name = "isp1router1.qcow2"
  pool = var.images_pool
  base_volume_id = libvirt_volume.vyos_image.id
}

resource "libvirt_cloudinit_disk" "isp1router1_cinit" {
  name = "isp1router1-commoninit.iso"
  pool = var.boot_pool
  meta_data = data.template_file.isp1router1_metadata.rendered
  user_data = data.template_file.isp1router1_userdata.rendered
}

resource "libvirt_cloudinit_disk" "isp1vps1_cinit" {
  name = "isp1vps1-commoninit.iso"
  pool = var.boot_pool
  meta_data = data.template_file.isp1vps1_metadata.rendered
  user_data = data.template_file.isp1vps1_userdata.rendered
}

resource "libvirt_cloudinit_disk" "isp1dns1_cinit" {
  name = "isp1dns1-commoninit.iso"
  pool = var.boot_pool
  meta_data = data.template_file.isp1dns1_metadata.rendered
  user_data = data.template_file.isp1dns1_userdata.rendered
}

data "template_file" "isp1router1_metadata" {
  template = file("../cloud-init/isp1router1/meta-data")
}

data "template_file" "isp1router1_userdata" {
  template = file("../cloud-init/isp1router1/user-data")
}

data "template_file" "isp1vps1_metadata" {
  template = file("../cloud-init/isp1vps1/meta-data")
}

data "template_file" "isp1vps1_userdata" {
  template = file("../cloud-init/isp1vps1/user-data")
}

data "template_file" "isp1dns1_metadata" {
  template = file("../cloud-init/isp1dns1/meta-data")
}

data "template_file" "isp1dns1_userdata" {
  template = file("../cloud-init/isp1dns1/user-data")
}

resource "libvirt_domain" "isp1router1" {
  name = "isp1router1"
  memory = "512"
  vcpu = "1"
  cpu {
    mode = "host-passthrough"
  }
  #metadata = data.template_file.isp1router1_metadata.rendered
  #user_data = data.template_file.user_data.rendered
  cloudinit = libvirt_cloudinit_disk.isp1router1_cinit.id

  # eth0
  network_interface {
    network_name = "isp1net1"
  }

  # eth1
  network_interface {
    network_name = "isp1-isp2"
  }

  # eth2
  network_interface {
    network_name = "isp6-isp1"
  }

  # eth3
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

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }

  disk {
    volume_id = libvirt_volume.isp1router1_vol.id
  }

}

resource "time_sleep" "wait_for_isp1router1" {
  depends_on = [libvirt_domain.isp1router1]
  create_duration = "90s"
}

resource "time_sleep" "wait_for_isp1dns1" {
  depends_on = [libvirt_domain.isp1dns1]
  create_duration = "45s"
}

resource "libvirt_domain" "isp1vps1" {
  depends_on = [time_sleep.wait_for_isp1dns1]
  name = "isp1vps1"
  memory = "1024"
  vcpu = "2"
  cpu {
    mode = "host-passthrough"
  }
  cloudinit = libvirt_cloudinit_disk.isp1vps1_cinit.id
  
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


resource "libvirt_domain" "isp1dns1" {
  depends_on = [time_sleep.wait_for_isp1router1]
  name = "isp1dns1"
  memory = "1024"
  vcpu = "2"
  cpu {
    mode = "host-passthrough"
  }
  cloudinit = libvirt_cloudinit_disk.isp1dns1_cinit.id
  
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
    volume_id = libvirt_volume.isp1dns1_vol.id
  }

}
