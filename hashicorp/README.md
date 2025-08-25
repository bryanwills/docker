For updating the organization name later:

  You only need to update the .env file, not the docker-compose.yml file. Here's why:

  - .env file contains: GITHUB_ORGANIZATION=bryanwillsorg
  - docker-compose.yml references: ${GITHUB_ORGANIZATION} (pulls from .env)
  - vault-setup.sh uses: "${GITHUB_ORGANIZATION}" (gets the value automatically)

  To change organization later:
  1. Edit /home/bryanwi09/docker/hasicorp/.env
  2. Change GITHUB_ORGANIZATION=neworgname
  3. Remove the config marker: rm /home/bryanwi09/docker/hasicorp/vault-data/.vault-configured
  4. Restart: docker compose down && docker compose up -d

  For the OIDC issue:
  The OIDC is asking for a role because GitHub doesn't support standard OIDC discovery. The GitHub OAuth through OIDC is more complex to set up
  properly. Since the GitHub Personal Access Token method is working perfectly and is actually more secure for individual use, you might want to stick
  with that method.

  Current working authentication methods:
  - ✅ GitHub PAT - Working perfectly
  - ✅ Username/Password - admin/myroot (backup)
  - ✅ Root Token - myroot (emergency access)
  - ⚠️ OIDC - Needs role input (partially working)

  The GitHub PAT method is actually the preferred approach for HashiCorp Vault GitHub authentication in most enterprise environments!