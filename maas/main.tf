terraform {
  required_providers {
    maas = {
      source  = "maas/maas"
      version = "~>1.0"
    }
    local = {
      source = "hashicorp/local"
      version = "2.4.0"
    }
  }
}

provider "local" {
  # Configuration options
}
provider "maas" {
  api_version = "2.0"
  api_key = var.maas_api_key
  api_url = "http://${var.maas_api_url}:5240/MAAS"
}


resource "maas_instance" "juju_mnl" {
  count = 1
  allocate_params {
    # hostname = "k8s-node-${count.index}"
    pool = "default"
    zone = "default"
    # min_cpu_count = 2
    # min_memory = 4096
    tags = [
      "juju-manual",
    ]
  }
  deploy_params {
    distro_series = "jammy"
  }
  network_interfaces {
        name = "eth0"
        ip_address = "10.10.32.8${0+count.index}"
        subnet_cidr = "10.10.32.0/24"
    }
}

resource "maas_instance" "k8s_nodes" {
  count = 3
  allocate_params {
    hostname = "k8s-node-${count.index}"
    pool = "default"
    zone = "default"
    # min_cpu_count = 2
    # min_memory = 4096
    tags = [
      "tigera",
    ]
  }
  deploy_params {
    distro_series = "jammy"
    user_data = templatefile("${path.module}/templates/cloud-init-example.tpl", {
      student_name = var.student_name
    })
  }
  network_interfaces {
        name = "eth0"
        ip_address = "10.10.32.${12+count.index}"
        subnet_cidr = "10.10.32.0/24"
    }
  network_interfaces {
        name = "eth1"
        ip_address = "10.10.10.${12+count.index}"
        subnet_cidr = "10.10.10.0/24"
    }
  network_interfaces {
        name = "eth2"
        ip_address = "10.10.20.${12+count.index}"
        subnet_cidr = "10.10.20.0/24"
  }
}

# locals {
#   nodes = flatten([
#     for i, node in maas_instance.k8s_nodes : {
#         hostname = "k8s-node-${0+i}",
#         stableIP = "10.30.30.${12+i}",
#         stableIPASN = "${64512+i}",
#         rackName = "rack1",
#         sw1Interface = "10.10.10.${12+i}",
#         sw1IP = "10.10.10.3",
#         sw1ASN = "65021",
#         sw2Interface = "10.10.20.${12+i}",
#         sw2IP = "10.10.20.3",
#         sw2ASN = "65031"
#     }
#   ])
# }

# resource "local_file" "generated_bundle" {
#   content = templatefile("${path.module}/templates/bundle.tpl", { nodes = local.nodes })
#   filename = "${path.module}/generated-bundle.yaml"
# }
