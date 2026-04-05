# Forrest Hill Infrastructure (fhs-infra)

This repository manages the infrastructure and orchestration for the Forrest Hill School digital properties, including the primary Craft CMS website, the Svelte-based FHSTV frontend, and the Calendar Sync service.

## Modernized Docker Architecture

The core infrastructure for the main Craft CMS application (`forresthill-postgres`) has been refactored to align with modern best practices for performance, security, and developer experience.

### Key Architectural Features:
1.  **Optimized Base Image:** Uses `serversideup/php:8.2-fpm-alpine`. This image is specifically tuned for PHP performance and provides non-root user mapping via `PUID` and `PGID`.
2.  **Multi-Stage Builds:** The `Dockerfile` uses a layered approach to build frontend assets (Node.js) and install PHP dependencies (Composer), ensuring the final runtime image is lean and contains no unnecessary build tools.
3.  **Clean Environment Separation:** The Docker configuration is split into base (`docker-compose.yml`), development (`docker-compose.override.yml`), and production (`docker-compose.prod.yml`) configurations.
4.  **Integrated Queue Worker:** A dedicated container running `./craft queue/listen` handles background tasks independently of web requests.
5.  **Local SMTP Catching:** [Mailpit](http://mailpit.localhost) is integrated into the development environment to safely intercept and preview outgoing emails.
6.  **Unified Caddy Proxy:** Caddy handles all local routing (including subdomains for Mailpit, FHSTV, and the API) and manages automatic HTTPS in production.

## Active Projects
- **Craft CMS Website**: `apps/forresthill-postgres`
- **FHSTV (Svelte 5)**: `apps/fhstv-svelte-5`
- **Calendar Sync (Rust)**: `apps/fhs-calendar-sync`
