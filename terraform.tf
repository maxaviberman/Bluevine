variable "aws_region" {
  type    = string
  default = "eu-west-1"
  description = "The AWS Region to use"
}

variable "http_listener_port" {
  type    = number
  default = 80
  description = "The HTTP Listener port"
}
