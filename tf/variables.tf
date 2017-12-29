variable "key_name" {
  description = "Name of the SSH keypair to use in AWS."
  default = "KEAO_LDN"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "eu-west-2"
}

# Ubuntu 16.04 LTS
variable "aws_amis" {
  default = {
    "eu-west-2" = "ami-fcc4db98"
  }
}
