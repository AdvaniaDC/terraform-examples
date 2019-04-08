variable "login_server_image" {
  default = "CentOS-7-x86_64-rbd"
}

variable "login_server_flavor" {
  default = "ecs.c4.large"
}

variable "compute_node_image" {
  default = "CentOS-7.6-BareMetal-x86_64"
}

variable "compute_node_flavor" {
  default = "bm.gphpc4.8xlarge"
}


variable "compute_node_count" {
  default = 2
}

variable "ssh_key_file" {
  default = "~/.ssh/id_rsa"
}

variable "ssh_user_name" {
  default = "centos"
}

variable "pool" {
  default = "public"
}

variable "project_name" {
  default = "project"
}
