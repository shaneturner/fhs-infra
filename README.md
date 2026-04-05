# FHS Infrastructure Orchestration

This repository provides a unified Docker-based infrastructure for the Forrest Hill School digital ecosystem. It ties together the main CMS, the FHSTV portal, and the Calendar Synchronization service into a single, manageable environment.

## Architecture

This project uses Git Submodules to manage the individual application repositories and Docker Compose Overrides to switch between development and production modes.

- **apps/forresthill-postgres**: Craft CMS (PHP 8.2-FPM + PostgreSQL 16)
  - **Optimized Base Image**: Uses `serversideup/php` for better performance and security.
  - **Multi-Stage Build**: Separates build tools from the final runtime image.
  - **Queue Worker**: Dedicated container running `./craft queue/listen` for background tasks.
  - **Mailpit**: Integrated mail catcher for local SMTP testing.
- **apps/fhstv-svelte-5**: Svelte 5 Frontend (SSG)
- **apps/fhs-calendar-sync**: Rust Calendar Sync API

---

## Getting Started

### 1. Clone the Repository
Since this project uses submodules, you must clone recursively:
```bash
git clone --recursive <repo-url> fhs-infra
cd fhs-infra
```

### 2. Initial Setup (including Git LFS)
Run the setup script to ensure all submodules are initialized and Git LFS assets (images/media) are correctly pulled for all projects:
```bash
./scripts/setup.sh
```

### 3. Configuration
Copy the example environment file and adjust your local settings:
```bash
cp .env.example .env
```
*Note: Ensure you have the necessary .env and secret files (like semper-service-account.json) inside the respective apps/ folders.*

### 4. Local Development
To start the unified development environment with hot-reloading:
```bash
docker compose up
```

**Access Points:**
- **Main Website**: [http://forresthill.localhost](http://forresthill.localhost)
- **Mailpit Dashboard**: [http://mailpit.localhost](http://mailpit.localhost)
- **FHSTV (Dev Server)**: [http://fhstv.localhost](http://fhstv.localhost)
- **Calendar API**: [http://api.forresthill.localhost](http://api.forresthill.localhost)

---

## Production Deployment

The production environment uses optimized builds (static binaries for Rust, SSG for Svelte) and serves everything via Caddy with automatic HTTPS.

### 1. Build and Start
```bash
docker compose -f docker-compose.yml -f docker-compose.prod.yml up --build -d
```

### 2. Domain Management
Update the `SITE_DOMAIN`, `FHSTV_DOMAIN`, and `API_DOMAIN` in your root `.env` to point to your live production domains. Caddy will automatically handle SSL certificate provisioning.

---

## Maintenance

### Updating Submodules and LFS Assets
To pull the latest changes and media for all applications:
```bash
./scripts/setup.sh
```

To verify that all LFS assets have been correctly pulled:
```bash
./scripts/check-lfs.sh
```

### Viewing Logs
```bash
docker compose logs -f
```
