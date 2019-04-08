data "openstack_networking_network_v2" "public" {
  name = "${var.pool}"
}

data "openstack_images_image_v2" "login_server_image" {
  name = "${var.login_server_image}"
  most_recent = true
}

data "openstack_images_image_v2" "compute_node_image" {
  name = "${var.compute_node_image}"
  most_recent = true
}
