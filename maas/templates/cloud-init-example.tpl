#cloud-config
write_files:
- content: |
    #!/bin/bash
    echo "Hello Terraform ${student_name}" > /home/ubuntu/hello.txt
    

  path: /tmp/setup-env.sh
  permissions: "0744"
  owner: root:root
packages:
- git
- zsh
runcmd:
- [/tmp/setup-env.sh]
