# Production Server Setup Guide: Forrest Hill Infrastructure

This guide outlines the step-by-step process for provisioning, securing, and deploying the Forrest Hill digital infrastructure on a fresh Linux production server (e.g., Ubuntu 24.04 LTS or Debian 12).

---

## Phase 1: Server Provisioning & Security

### 1. Create a Non-Root User
Never run your application or Docker containers as the `root` user.
```bash
# Log in as root
ssh root@your_server_ip

# Create a new user (e.g., 'deploy')
adduser deploy

# Add the user to the sudo group
usermod -aG sudo deploy

# Switch to the new user
su - deploy
```

### 2. Secure SSH Access
Set up SSH key authentication and disable password login.
```bash
# On your local machine, copy your public key to the server
ssh-copy-id deploy@your_server_ip

# Back on the server, edit the SSH config
sudo nano /etc/ssh/sshd_config

# Find and change these lines:
PermitRootLogin no
PasswordAuthentication no

# Restart the SSH service
sudo systemctl restart ssh
```

### 3. Configure the Firewall (UFW)
Only allow essential traffic (SSH, HTTP, HTTPS).
```bash
sudo ufw allow OpenSSH
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

### 4. Install Fail2Ban (Optional but Recommended)
Protects against brute-force SSH attacks.
```bash
sudo apt update
sudo apt install fail2ban -y
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

---

## Phase 2: Install Dependencies

### 1. Install Docker & Docker Compose
Follow the official Docker installation instructions to ensure you get the latest version (do not use the default apt repository version).
```bash
# Add Docker's official GPG key
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Install Docker packages
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Add your user to the docker group to run commands without sudo
sudo usermod -aG docker $USER
# Log out and log back in to apply group changes
```

### 2. Install Git and Git LFS
Required for pulling the repository and managing large media assets.
```bash
sudo apt install git git-lfs -y
git lfs install
```

---

## Phase 3: Project Deployment

### 1. Clone the Repository
Since the project uses submodules, use the `--recursive` flag.
```bash
# Generate an SSH key on the server if you are cloning via SSH (recommended)
ssh-keygen -t ed25519 -C "server-deploy-key"
# Add the public key (~/.ssh/id_ed25519.pub) as a Deploy Key in your GitHub repository settings

git clone --recursive git@github.com:shaneturner/fhs-infra.git
cd fhs-infra
```

### 2. Initialize and Pull Assets
Run the automated setup script to ensure all submodules are initialized and Git LFS assets are pulled.
```bash
./scripts/setup.sh

# Verify all LFS assets are present
./scripts/check-lfs.sh
```

### 3. Environment Configuration
Create the root environment file and the Craft CMS environment file.
```bash
cp .env.example .env
cp apps/forresthill-postgres/.env.example apps/forresthill-postgres/.env
```

**Crucial Production Variables:**

**In root `.env`:**
```env
# Set your live domains for Caddy routing and SSL generation
SITE_DOMAIN=forresthill.school.nz
FHSTV_DOMAIN=tv.forresthill.school.nz
API_DOMAIN=api.forresthill.school.nz

# Email for Let's Encrypt SSL registration
CADDY_EMAIL=admin@forresthill.school.nz
```

**In `apps/forresthill-postgres/.env`:**
```env
ENVIRONMENT=production
CRAFT_STREAM_LOG=1

# Strong Security Key
CRAFT_SECURITY_KEY=generate_a_long_random_string_here

# Database Credentials (Change these from defaults!)
DB_USER=craft_prod_user
DB_PASSWORD=strong_prod_password
DB_DATABASE=craft_pg_prod

# Production OPcache Optimizations
PHP_OPCACHE_ENABLE=1
PHP_OPCACHE_MEMORY_CONSUMPTION=256
PHP_OPCACHE_REVALIDATE_FREQ=0
```

### 4. Start the Production Environment
Use both the base configuration and the production override file to spin up the immutable, optimized environment.
```bash
docker compose -f docker-compose.yml -f docker-compose.prod.yml up --build -d
```

### 5. Run Database Migrations (First Time Only)
If this is a new server, apply the database schema.
```bash
docker exec fhs-craft-app php craft up
```

---

## Phase 4: Ongoing Maintenance

### Updating the Site
When you merge new changes into your `main` branches on GitHub, SSH into the server and run:
```bash
cd ~/fhs-infra

# Update the main repository and all submodules
git pull origin main
./scripts/sync-submodules.sh

# Rebuild and restart the containers with the new code
docker compose -f docker-compose.yml -f docker-compose.prod.yml up --build -d

# Run any pending migrations
docker exec fhs-craft-app php craft up
```

### Database Backups
Craft CMS provides built-in backup tools. To automate them, you can set up a cron job on the host machine:
```bash
# Add a cron job that runs daily at 2 AM
0 2 * * * cd /home/deploy/fhs-infra && docker exec fhs-craft-app php craft db/backup
```
*Backups will be saved to `apps/forresthill-postgres/storage/backups/`.*
