variable "docker_host" {
  description = "Docker daemon socket. Use unix:///var/run/docker.sock for local."
  type        = string
  default     = "unix:///var/run/docker.sock"
}

variable "demo_container_name" {
  description = "Name to give the demo nginx container."
  type        = string
  default     = "tofu-demo-nginx"
}

variable "demo_host_port" {
  description = "Host port to map for the demo container."
  type        = number
  default     = 8099
}
