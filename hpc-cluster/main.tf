resource "openstack_compute_keypair_v2" "terraform" {
  name       = "terraform"
  public_key = "${file("${var.ssh_key_file}.pub")}"
}

resource "openstack_networking_network_v2" "private_network" {
  name           = "${var.project_name}-private-network"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "private_network_subnet" {
  name            = "${var.project_name}-private-network-subnet"
  network_id      = "${openstack_networking_network_v2.private_network.id}"
  cidr            = "192.168.100.0/24"
  ip_version      = 4
  dns_nameservers = ["192.168.100.10"]
  allocation_pools {
    start = "192.168.100.10"
    end= "192.168.100.250"
  }
}

resource "openstack_networking_router_v2" "router" {
  name                = "${var.project_name}-router"
  admin_state_up      = "true"
  external_network_id = "${data.openstack_networking_network_v2.public.id}"
}

resource "openstack_networking_router_interface_v2" "router_connect_private_network" {
  router_id = "${openstack_networking_router_v2.router.id}"
  subnet_id = "${openstack_networking_subnet_v2.private_network_subnet.id}"
}

resource "openstack_networking_secgroup_v2" "login_security_group" {
  name        = "${var.project_name}-login-security-group"
  description = "Security group for the Login server"
}

resource "openstack_networking_secgroup_rule_v2" "login_security_group_22" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.login_security_group.id}"
}

resource "openstack_networking_secgroup_rule_v2" "login_security_group_ping" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.login_security_group.id}"
}

resource "openstack_networking_secgroup_rule_v2" "login_security_group_nfs_tcp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 2049
  port_range_max    = 2049
  remote_ip_prefix  = "192.168.100.0/24"
  security_group_id = "${openstack_networking_secgroup_v2.login_security_group.id}"
}

resource "openstack_networking_secgroup_rule_v2" "login_security_group_nfs_udp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 2049
  port_range_max    = 2049
  remote_ip_prefix  = "192.168.100.0/24"
  security_group_id = "${openstack_networking_secgroup_v2.login_security_group.id}"
}

resource "openstack_networking_floatingip_v2" "login_floating_ip" {
  pool = "${var.pool}"
}

resource "openstack_compute_instance_v2" "login_server" {
  name            = "login"
  flavor_name     = "${var.login_server_flavor}"
  key_pair        = "${openstack_compute_keypair_v2.terraform.name}"
  security_groups = ["${openstack_networking_secgroup_v2.login_security_group.name}"]

  block_device {
    uuid                  = "${data.openstack_images_image_v2.login_server_image.id}"
    source_type           = "image"
    destination_type      = "volume"
    boot_index            = 0
    delete_on_termination = true
    volume_size           = 20
  }

  network {
    uuid = "${openstack_networking_network_v2.private_network.id}"
  }

  user_data = "${file("user-data/login.sh")}"
}

resource "openstack_compute_floatingip_associate_v2" "login_server_floating_ip" {
  floating_ip = "${openstack_networking_floatingip_v2.login_floating_ip.address}"
  instance_id = "${openstack_compute_instance_v2.login_server.id}"

  provisioner "file" {
    connection {
      host        = "${openstack_networking_floatingip_v2.login_floating_ip.address}"
      user        = "${var.ssh_user_name}"
      private_key = "${file(var.ssh_key_file)}"
    }
    source      = "scripts/login_user.sh"
    destination = "/tmp/login_user.sh"
  }

  provisioner "file" {
    connection {
      host        = "${openstack_networking_floatingip_v2.login_floating_ip.address}"
      user        = "${var.ssh_user_name}"
      private_key = "${file(var.ssh_key_file)}"
    }
    source      = "scripts/login.sh"
    destination = "/tmp/login.sh"
  }

  provisioner "remote-exec" {
    connection {
      host        = "${openstack_networking_floatingip_v2.login_floating_ip.address}"
      user        = "${var.ssh_user_name}"
      private_key = "${file(var.ssh_key_file)}"
    }

    inline = [
      "chmod +x /tmp/login.sh /tmp/login_user.sh",
      "sudo /tmp/login.sh",
      "/tmp/login_user.sh",
    ]
  }
}



resource "openstack_compute_instance_v2" "compute_node" {
  count = "${var.compute_node_count}"
  name = "${format("node-%03d", count.index+1)}"
  image_name = "${var.compute_node_image}"
  flavor_name = "${var.compute_node_flavor}"
  key_pair = "${openstack_compute_keypair_v2.terraform.name}"
  security_groups = ["default"]

  network {
    uuid = "${openstack_networking_network_v2.private_network.id}"
  }

  user_data = "${file("user-data/compute.sh")}"
}
