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

variable "es_password" {
  type    = string
  default = "dummy_password"
  description = "ES Password - do not keep passwrod in clear"
}
