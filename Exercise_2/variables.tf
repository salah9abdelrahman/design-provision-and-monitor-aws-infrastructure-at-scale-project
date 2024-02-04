# TODO: Define the variable for aws_region

variable "region" {
  default = "us-east-1"
}

variable "greet_lambda" {
  default = "greet_lambda"
  type = string
}