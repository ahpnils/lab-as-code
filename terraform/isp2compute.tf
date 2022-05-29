resource "libvirt_volume" "isp2dns1_vol" {
  name = "isp2dns1.qcow2"
  pool = "nils_images"
  base_volume_id = libvirt_volume.fedora_image.id
}

resource "libvirt_volume" "isp2router1_vol" {
  name = "isp2router1.qcow2"
  pool = "nils_images"
  base_volume_id = libvirt_volume.vyos_image.id
}

resource "libvirt_cloudinit_disk" "isp2router1_cinit" {
  name = "isp2router1-commoninit.iso"
  pool = "nils_boot"
  meta_data = data.template_file.isp2router1_metadata.rendered
  user_data = data.template_file.isp2router1_userdata.rendered
}

resource "libvirt_cloudinit_disk" "isp2dns1_cinit" {
  name = "isp2dns1-commoninit.iso"
  pool = "nils_boot"
  meta_data = data.template_file.isp2dns1_metadata.rendered
  user_data = data.template_file.isp2dns1_userdata.rendered
}

data "template_file" "isp2router1_metadata" {
  template = file("../cloud-init/isp2router1/meta-data")
}

data "template_file" "isp2router1_userdata" {
  template = file("../cloud-init/isp2router1/user-data")
}

data "template_file" "isp2dns1_metadata" {
  template = file("../cloud-init/isp2dns1/meta-data")
}

data "template_file" "isp2dns1_userdata" {
  template = file("../cloud-init/isp2dns1/user-data")
}

resource "libvirt_domain" "isp2router1" {
  name = "isp2router1"
  memory = "512"
  vcpu = "1"
  cpu {
    mode = "host-passthrough"
  }
  #metadata = data.template_file.isp2router1_metadata.rendered
  #user_data = data.template_file.user_data.rendered
  cloudinit = libvirt_cloudinit_disk.isp2router1_cinit.id

  # eth0
  network_interface {
    network_name = "isp2net1"
  }

  # eth1
  network_interface {
    network_name = "isp2-isp3"
  }

  # eth2
  network_interface {
    network_name = "isp1-isp2"
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
    volume_id = libvirt_volume.isp2router1_vol.id
  }

}

resource "time_sleep" "isp2_sleep_60s" {
  depends_on = [libvirt_domain.isp2router1]
  create_duration = "60s"
}

resource "libvirt_domain" "isp2dns1" {
  depends_on = [time_sleep.isp2_sleep_60s]
  name = "isp2dns1"
  memory = "1024"
  vcpu = "2"
  cpu {
    mode = "host-passthrough"
  }
  cloudinit = libvirt_cloudinit_disk.isp2dns1_cinit.id
  
  network_interface {
    network_name = "isp2net1"
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
    volume_id = libvirt_volume.isp2dns1_vol.id
  }

}
