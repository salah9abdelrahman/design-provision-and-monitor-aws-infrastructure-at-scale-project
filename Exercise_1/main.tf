# TODO: Designate a cloud provider, region, and credentials
provider "aws" {
  region = "us-east-1"
  access_key = ""
  secret_key = ""
}

variable "public_subnet_1a" {
  type    = string
  default = "subnet-0861e43ebcc21d9f4"
}

# TODO: provision 4 AWS t2.micro EC2 instances named Udacity T2

resource "aws_instance" "t2_micro" {
  subnet_id = var.public_subnet_1a

  ami           = "ami-0277155c3f0ab2930"
  instance_type = "t2.micro"
  count         = 4

  tags = {
    Name = "Udacity T2"
  }
}

