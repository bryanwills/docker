# Ansible (Personal VPS)

Semaphore UI + an Ansible project (Galaxy + Molecule-tested roles) for the VPS.

```
ansible/
├── docker-compose.yml          # Semaphore UI (BoltDB) behind Traefik
├── .env.example                # copy -> .env, set admin pw + encryption key
└── project/                    # the ansible content (mounted into Semaphore at /ansible)
    ├── ansible.cfg
    ├── requirements.yml         # Galaxy collections
    ├── molecule-requirements.txt
    ├── inventory/hosts.ini
    ├── playbooks/demo-zsh.yml
    ├── roles/zsh/               # example role, Molecule-tested
    │   └── molecule/default/    # molecule.yml / converge.yml / verify.yml
    └── scripts/discover-hosts.sh
```

## 1. Start Semaphore
```bash
cd /home/bryanwi09/docker/ansible
cp .env.example .env
# set SEMAPHORE_ADMIN_PASSWORD and generate the key:
head -c32 /dev/urandom | base64        # paste into SEMAPHORE_ACCESS_KEY_ENCRYPTION
docker compose up -d
```
Open <https://ansible.bryanwills.dev> (add the Traefik DNS record if needed) and
log in with the admin creds from `.env`. In Semaphore: create a Project →
point it at this repo (or the mounted `/ansible`) → add an inventory, an SSH
key, and Task Templates for `playbooks/demo-zsh.yml`.

## 2. Run the demo playbook from the CLI
```bash
cd project
ansible-galaxy install -r requirements.yml
ansible-playbook playbooks/demo-zsh.yml                 # localhost
ansible-playbook playbooks/demo-zsh.yml -e target=vps   # a group
```
The `zsh` role checks whether zsh is installed and installs it if not.

## 3. Test the role with Molecule
Easiest — the helper bootstraps a venv (system pip is locked down here) and runs
Molecule for you:
```bash
cd project
./scripts/molecule-test.sh            # 'molecule test' on the zsh role
./scripts/molecule-test.sh zsh converge   # iterate without teardown
./scripts/molecule-test.sh zsh login      # shell into the test container
```
Manual equivalent:
```bash
python3 -m venv .venv && source .venv/bin/activate
pip install -r project/molecule-requirements.txt
cd project/roles/zsh && molecule test   # Ubuntu+Debian containers: run, verify, destroy
```
Molecule needs Docker (already on this host).

## 4. Lint & CI
- `project/.yamllint` and `project/.ansible-lint` configure linting. Run from
  `project/`: `yamllint .` and `ansible-lint`.
- `project/ci/github-actions-molecule.yml.example` is a ready CI job — copy it to
  the **repo root** at `~/docker/.github/workflows/molecule.yml` to run lint +
  `molecule test` on every push (paths/role dir are pre-filled for this repo).

## Notes
- BoltDB keeps this single-file and simple; switch `SEMAPHORE_DB_DIALECT` to
  `postgres` (add a db service) if you outgrow it.
- `discover-hosts.sh` here just inventories Docker containers — a network scan
  is meaningless on the public VPS. The work copy does real subnet discovery.
