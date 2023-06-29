terraform {
  required_providers {
    ssh = {
      source = "loafoe/ssh"
      version = "2.6.0"
    }
  }
}

provider "ssh" {
  # Configuration options
}

resource "ssh_resource" "get_api_key" {
  triggers = {
    always_run = "${timestamp()}"
  }

  host         = "${module.maas_tf_lab.maas_instance_ip}"
  user         = "ubuntu"
  agent        = true

  commands = [
     "maas apikey --user root"
  ]
}



module "maas_tf_lab" {
    source = "./baremetal"
}

# module "maas_provider_example" {
#     source = "./maas"
#     maas_api_url = "${module.maas_tf_lab.maas_instance_ip}"
#     maas_api_key = "${ssh_resource.get_api_key.result}"
#     student_name = "TODO"
# }

