resource "libvirt_volume" "isp6vps1_vol" {
  name = "isp6vps1.qcow2"
  pool = var.images_pool
  base_volume_id = libvirt_volume.fedora_image.id
}

resource "libvirt_volume" "isp6router1_vol" {
  name = "isp6router1.qcow2"
  pool = var.images_pool
  base_volume_id = libvirt_volume.vyos_image.id
}

resource "libvirt_cloudinit_disk" "isp6router1_cinit" {
  name = "isp6router1-commoninit.iso"
  pool = var.boot_pool
  meta_data = data.template_file.isp6router1_metadata.rendered
  user_data = data.template_file.isp6router1_userdata.rendered
}

resource "libvirt_cloudinit_disk" "isp6vps1_cinit" {
  name = "isp6vps1-commoninit.iso"
  pool = var.boot_pool
  meta_data = data.template_file.isp6vps1_metadata.rendered
  user_data = data.template_file.isp6vps1_userdata.rendered
}

data "template_file" "isp6router1_metadata" {
  template = file("../cloud-init/isp6router1/meta-data")
}

data "template_file" "isp6router1_userdata" {
  template = file("../cloud-init/isp6router1/user-data")
}

data "template_file" "isp6vps1_metadata" {
  template = file("../cloud-init/isp6vps1/meta-data")
}

data "template_file" "isp6vps1_userdata" {
  template = file("../cloud-init/isp6vps1/user-data")
}

resource "libvirt_domain" "isp6router1" {
  depends_on = [time_sleep.wait_for_isp1dns1]
  name = "isp6router1"
  memory = "512"
  vcpu = "1"
  cpu {
    mode = "host-passthrough"
  }
  #metadata = data.template_file.isp6router1_metadata.rendered
  #user_data = data.template_file.user_data.rendered
  cloudinit = libvirt_cloudinit_disk.isp6router1_cinit.id

  # eth0
  network_interface {
    network_name = "isp6net1"
  }

  # eth1
  network_interface {
    network_name = "isp6-isp1"
  }

  # eth2
  network_interface {
    network_name = "isp5-isp6"
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
    volume_id = libvirt_volume.isp6router1_vol.id
  }

}

resource "time_sleep" "wait_for_isp6router1" {
  depends_on = [libvirt_domain.isp6router1]
  create_duration = "75s"
}

resource "libvirt_domain" "isp6vps1" {
  depends_on = [time_sleep.wait_for_isp6router1]
  name = "isp6vps1"
  memory = "1024"
  vcpu = "2"
  cpu {
    mode = "host-passthrough"
  }
  cloudinit = libvirt_cloudinit_disk.isp6vps1_cinit.id
  
  network_interface {
    network_name = "isp6net1"
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
    volume_id = libvirt_volume.isp6vps1_vol.id
  }

}

