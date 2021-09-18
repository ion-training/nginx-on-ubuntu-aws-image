packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

# Default region is "eu-central-1", however you can modify the region by using --var flag on the CLI while building the image.
variable "region" {
    type = string
    default = "eu-central-1"
}

variable "ami_prefix" {
    type = string
    default = "nginx-on-ubuntu-aws"
}

locals {
    timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "${var.ami_prefix}-${local.timestamp}"
  instance_type = "t2.micro"
  region        = "${var.region}"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-xenial-16.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

build {
  name    = "nginx-on-ubuntu"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "shell" {
      environment_vars = [
        "DEBIAN_FRONTEND=noninteractive",
  ]
    inline = [
      "sudo apt-get update",
      "sudo apt-get -y install nginx",
    ]
  }

}
