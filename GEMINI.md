# Forrest Hill Infrastructure (fhs-infra)

This repository manages the infrastructure and orchestration for the Forrest Hill School digital properties, including the primary Craft CMS website, the Svelte-based FHSTV frontend, and the Calendar Sync service.

## Active Refactoring Plan

We are currently refactoring the Docker setup for the main Craft CMS application (`forresthill-postgres`) to align with modern best practices for both local development and production deployments. 

The complete plan and checklist can be found here: `plans/docker-refactor-plan.md`

### High-Level Goals of the Refactor:
1.  **Adopt Optimized Base Images:** Migrating to `serversideup/php:8.2-fpm-nginx` for better performance and security.
2.  **Multi-Stage Builds:** Creating a production-ready `Dockerfile` that separates build dependencies (Composer, Node) from the final runtime image.
3.  **Environment Separation:** Splitting the monolithic compose setup into:
    *   `docker-compose.yml` (Base services)
    *   `docker-compose.override.yml` (Local dev overrides, volume mounts)
    *   `docker-compose.prod.yml` (Production overrides)
4.  **New Services:** Adding a dedicated Craft Queue worker and Mailpit for local SMTP testing.