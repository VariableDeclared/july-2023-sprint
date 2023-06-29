terraform {
  required_providers {
    lxd = {
      source  = "terraform-lxd/lxd"
      version = "1.9.1"
    }
  }
}


provider "lxd" {
}


resource "lxd_project" "terraform_primer" {
  name        = "terraform-primer"
  description = "MAAS VM Sandbox."
  config = {
    "features.images" = false
  }

}

locals {
  node_hostname = "maas-node-0"
}

resource "lxd_network" "maas_lab_net" {
  name = "maas-lab-net"

  config = {
    "ipv4.address" = "10.150.18.1/24"
    "ipv4.nat"     = "true"
    "ipv6.address" = "none"
    "ipv6.nat"     = "false"
  }
}

resource "lxd_container" "MAAS" {
  name      = "${local.node_hostname}"
  image     = "ubuntu:jammy"
  ephemeral = false
  type      = "virtual-machine"
#   profiles  = ["${lxd_profile.dual_tor_profile.name}"]
  project = lxd_project.terraform_primer.name
  device {
    name = "root"
    type = "disk"

    properties = {
      pool    = "default"
      size    = "50GiB"
      path    = "/"
    }
  }
  device {
    name = "eth1"
    type = "nic"

    properties = {
      nictype = "bridged"
      parent  =  "${lxd_network.maas_lab_net.name}"
    }
  }

  config = {
    "boot.autostart"       = true
    "cloud-init.user-data" = templatefile("${path.module}/templates/maas-cloud-init.tpl", { 
      node_hostname = "${local.node_hostname}"
    })
  }

  limits = {
    cpu = 2
    memory = "8GiB"
  }
}