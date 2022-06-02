resource "libvirt_volume" "isp3vps1_vol" {
  name = "isp3vps1.qcow2"
  pool = "nils_images"
  base_volume_id = libvirt_volume.fedora_image.id
}

resource "libvirt_volume" "isp3vps2_vol" {
  name = "isp3vps2.qcow2"
  pool = "nils_images"
  base_volume_id = libvirt_volume.fedora_image.id
}

resource "libvirt_volume" "isp3vps3_vol" {
  name = "isp3vps3.qcow2"
  pool = "nils_images"
  base_volume_id = libvirt_volume.fedora_image.id
}

resource "libvirt_volume" "isp3router1_vol" {
  name = "isp3router1.qcow2"
  pool = "nils_images"
  base_volume_id = libvirt_volume.vyos_image.id
}

resource "libvirt_cloudinit_disk" "isp3router1_cinit" {
  name = "isp3router1-commoninit.iso"
  pool = "nils_boot"
  meta_data = data.template_file.isp3router1_metadata.rendered
  user_data = data.template_file.isp3router1_userdata.rendered
}

resource "libvirt_cloudinit_disk" "isp3vps1_cinit" {
  name = "isp3vps1-commoninit.iso"
  pool = "nils_boot"
  meta_data = data.template_file.isp3vps1_metadata.rendered
  user_data = data.template_file.isp3vps1_userdata.rendered
}

resource "libvirt_cloudinit_disk" "isp3vps2_cinit" {
  name = "isp3vps2-commoninit.iso"
  pool = "nils_boot"
  meta_data = data.template_file.isp3vps2_metadata.rendered
  user_data = data.template_file.isp3vps2_userdata.rendered
}

resource "libvirt_cloudinit_disk" "isp3vps3_cinit" {
  name = "isp3vps3-commoninit.iso"
  pool = "nils_boot"
  meta_data = data.template_file.isp3vps3_metadata.rendered
  user_data = data.template_file.isp3vps3_userdata.rendered
}

data "template_file" "isp3router1_metadata" {
  template = file("../cloud-init/isp3router1/meta-data")
}

data "template_file" "isp3router1_userdata" {
  template = file("../cloud-init/isp3router1/user-data")
}

data "template_file" "isp3vps1_metadata" {
  template = file("../cloud-init/isp3vps1/meta-data")
}

data "template_file" "isp3vps1_userdata" {
  template = file("../cloud-init/isp3vps1/user-data")
}

data "template_file" "isp3vps2_metadata" {
  template = file("../cloud-init/isp3vps2/meta-data")
}

data "template_file" "isp3vps2_userdata" {
  template = file("../cloud-init/isp3vps2/user-data")
}

data "template_file" "isp3vps3_metadata" {
  template = file("../cloud-init/isp3vps3/meta-data")
}

data "template_file" "isp3vps3_userdata" {
  template = file("../cloud-init/isp3vps3/user-data")
}

resource "libvirt_domain" "isp3router1" {
  depends_on = [time_sleep.isp1_sleep_30s]
  name = "isp3router1"
  memory = "512"
  vcpu = "1"
  cpu {
    mode = "host-passthrough"
  }
  #metadata = data.template_file.isp3router1_metadata.rendered
  #user_data = data.template_file.user_data.rendered
  cloudinit = libvirt_cloudinit_disk.isp3router1_cinit.id

  # eth0
  network_interface {
    network_name = "isp3net1"
  }

  # eth1
  network_interface {
    network_name = "isp3-isp4"
  }

  # eth2
  network_interface {
    network_name = "isp2-isp3"
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
    volume_id = libvirt_volume.isp3router1_vol.id
  }

}

resource "time_sleep" "isp3_sleep_60s" {
  depends_on = [libvirt_domain.isp3router1]
  create_duration = "60s"
}

resource "libvirt_domain" "isp3vps1" {
  depends_on = [time_sleep.isp3_sleep_60s]
  name = "isp3vps1"
  memory = "1024"
  vcpu = "2"
  cpu {
    mode = "host-passthrough"
  }
  cloudinit = libvirt_cloudinit_disk.isp3vps1_cinit.id
  
  network_interface {
    network_name = "isp3net1"
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
    volume_id = libvirt_volume.isp3vps1_vol.id
  }

}

resource "libvirt_domain" "isp3vps2" {
  depends_on = [time_sleep.isp3_sleep_60s]
  name = "isp3vps2"
  memory = "1024"
  vcpu = "2"
  cpu {
    mode = "host-passthrough"
  }
  cloudinit = libvirt_cloudinit_disk.isp3vps2_cinit.id
  
  network_interface {
    network_name = "isp3net1"
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
    volume_id = libvirt_volume.isp3vps2_vol.id
  }

}

resource "libvirt_domain" "isp3vps3" {
  depends_on = [time_sleep.isp3_sleep_60s]
  name = "isp3vps3"
  memory = "1024"
  vcpu = "2"
  cpu {
    mode = "host-passthrough"
  }
  cloudinit = libvirt_cloudinit_disk.isp3vps3_cinit.id
  
  network_interface {
    network_name = "isp3net1"
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
    volume_id = libvirt_volume.isp3vps3_vol.id
  }

}

