# Example 02 — Docker Provider
# ------------------------------
# Manages a real Docker container on this host using OpenTofu.
# Demonstrates how OpenTofu handles CREATE / UPDATE / DESTROY lifecycle.
#
# Requirements:
#   • The Semaphore container must have access to the Docker socket.
#     Add to ansible/docker-compose.yml under volumes:
#       - /var/run/docker.sock:/var/run/docker.sock
#
# Run from Semaphore:
#   Project type : OpenTofu
#   Playbook dir : /opentofu/examples/02-docker-provider
#   Environment  : TF_VAR_docker_host=unix:///var/run/docker.sock

provider "docker" {
  host = var.docker_host
}

data "docker_image" "nginx" {
  name = "nginx:alpine"
}

resource "docker_container" "demo" {
  name  = var.demo_container_name
  image = data.docker_image.nginx.id

  ports {
    internal = 80
    external = var.demo_host_port
  }

  labels {
    label = "managed-by"
    value = "opentofu"
  }

  restart = "unless-stopped"
}

output "container_id" {
  value = docker_container.demo.id
}

output "access_url" {
  value = "http://localhost:${var.demo_host_port}"
}
