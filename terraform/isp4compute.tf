resource "libvirt_volume" "isp4vps1_vol" {
  name = "isp4vps1.qcow2"
  pool = "nils_images"
  base_volume_id = libvirt_volume.fedora_image.id
}

resource "libvirt_volume" "isp4router1_vol" {
  name = "isp4router1.qcow2"
  pool = "nils_images"
  base_volume_id = libvirt_volume.vyos_image.id
}

resource "libvirt_cloudinit_disk" "isp4router1_cinit" {
  name = "isp4router1-commoninit.iso"
  pool = "nils_boot"
  meta_data = data.template_file.isp4router1_metadata.rendered
  user_data = data.template_file.isp4router1_userdata.rendered
}

resource "libvirt_cloudinit_disk" "isp4vps1_cinit" {
  name = "isp4vps1-commoninit.iso"
  pool = "nils_boot"
  meta_data = data.template_file.isp4vps1_metadata.rendered
  user_data = data.template_file.isp4vps1_userdata.rendered
}

data "template_file" "isp4router1_metadata" {
  template = file("../cloud-init/isp4router1/meta-data")
}

data "template_file" "isp4router1_userdata" {
  template = file("../cloud-init/isp4router1/user-data")
}

data "template_file" "isp4vps1_metadata" {
  template = file("../cloud-init/isp4vps1/meta-data")
}

data "template_file" "isp4vps1_userdata" {
  template = file("../cloud-init/isp4vps1/user-data")
}

resource "libvirt_domain" "isp4router1" {
  depends_on = [time_sleep.wait_for_isp3router1]
  name = "isp4router1"
  memory = "512"
  vcpu = "1"
  cpu {
    mode = "host-passthrough"
  }
  #metadata = data.template_file.isp4router1_metadata.rendered
  #user_data = data.template_file.user_data.rendered
  cloudinit = libvirt_cloudinit_disk.isp4router1_cinit.id

  # eth0
  network_interface {
    network_name = "isp4net1"
  }

  # eth1
  network_interface {
    network_name = "isp4-isp5"
  }

  # eth2
  network_interface {
    network_name = "isp3-isp4"
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
    volume_id = libvirt_volume.isp4router1_vol.id
  }

}

resource "time_sleep" "wait_for_isp4router1" {
  depends_on = [libvirt_domain.isp4router1]
  create_duration = "75s"
}

resource "libvirt_domain" "isp4vps1" {
  depends_on = [time_sleep.wait_for_isp4router1]
  name = "isp4vps1"
  memory = "1024"
  vcpu = "2"
  cpu {
    mode = "host-passthrough"
  }
  cloudinit = libvirt_cloudinit_disk.isp4vps1_cinit.id
  
  network_interface {
    network_name = "isp4net1"
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
    volume_id = libvirt_volume.isp4vps1_vol.id
  }

}

