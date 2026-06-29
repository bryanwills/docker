# Example 01 — Hello Local
# -------------------------
# This configuration uses only built-in providers (local + random).
# No cloud credentials required — perfect for learning the OpenTofu workflow:
#   tofu init  →  tofu plan  →  tofu apply  →  tofu destroy
#
# Run from Semaphore:
#   Project type : OpenTofu
#   Playbook dir : /opentofu/examples/01-hello-local
#   Environment  : (leave empty — no creds needed)

resource "random_pet" "name" {
  length    = 2
  separator = "-"
}

resource "local_file" "greeting" {
  content  = "Hello from OpenTofu! Generated name: ${random_pet.name.id}\n"
  filename = "/tmp/opentofu-hello.txt"
}

output "greeting_file" {
  value = local_file.greeting.filename
}

output "generated_name" {
  value = random_pet.name.id
}
