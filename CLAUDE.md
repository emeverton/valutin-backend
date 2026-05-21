# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository structure

Turborepo monorepo. The only app currently is `apps/backend` — a Medusa v2 headless commerce backend for the Valutin children's fashion brand.

## Commands

All commands run from the repo root unless noted otherwise.

```bash
# Development
npm run backend:dev          # start Medusa with hot reload (wraps `medusa develop`)

# Build & start (production)
npm run build                # build all apps
npm start                    # start all apps (requires build first)

# From apps/backend directly
cd apps/backend
npx medusa exec ./src/scripts/<script>.ts   # run a one-off exec script
npx medusa build                             # build the backend
```

### Tests (run from `apps/backend`)

```bash
npm run test:unit                     # unit tests in src/**/__tests__/*.unit.spec.ts
npm run test:integration:modules      # module integration tests in src/modules/*/__tests__/
npm run test:integration:http         # HTTP integration tests in integration-tests/http/
```

Tests use Jest + SWC. The `TEST_TYPE` env var controls which test glob jest picks up (see `jest.config.js`).

## Architecture

### Medusa v2 module system

Medusa v2 uses a container-based DI system. Services are resolved from the container via `Modules.*` or `ContainerRegistrationKeys.*` constants from `@medusajs/framework/utils`. The key container keys used in this project:

- `Modules.PRODUCT` → `IProductModuleService` (categories, products)
- `Modules.FULFILLMENT` → fulfillment sets and providers
- `ContainerRegistrationKeys.LOGGER` → structured logger
- `ContainerRegistrationKeys.LINK` → cross-module entity linking
- `ContainerRegistrationKeys.QUERY` → graph query across modules

### Extension points

Medusa v2 is extended through specific directories that are auto-loaded:

| Directory | Purpose |
|---|---|
| `src/api/` | Custom REST routes. File path maps to URL: `src/api/store/custom/route.ts` → `GET /store/custom`. Export named HTTP verb functions (`GET`, `POST`, etc.) |
| `src/workflows/` | Custom Medusa workflows (step-based, compensatable) |
| `src/subscribers/` | Event subscribers triggered by Medusa events |
| `src/jobs/` | Scheduled jobs |
| `src/modules/` | Custom Medusa modules with their own services and `__tests__/` |
| `src/links/` | Module link definitions (cross-module foreign keys) |
| `src/scripts/` | One-off exec scripts run with `medusa exec` |
| `src/migration-scripts/` | Data migration scripts (run via Medusa migration tooling) |
| `src/admin/` | Admin UI extensions (React components built with `@medusajs/ui`) |

### Seed scripts

Scripts in `src/scripts/` export a default async function receiving `{ container: MedusaContainer }`. They are idempotent by design — always check for existing data before creating. Run with:

```bash
npx medusa exec ./src/scripts/<name>.ts
```

`src/migration-scripts/initial-data-seed.ts` seeds the full store (sales channels, regions, shipping, products). `src/scripts/seed-categories.ts` seeds the six PT-BR product categories (bebe, crianca, calcados, acessorios, ocasioes, quarto).

### Configuration

`medusa-config.ts` at `apps/backend/` root defines database URL, CORS origins, and JWT/cookie secrets via env vars. Copy `.env.template` to `.env` and fill in `DATABASE_URL` before running locally.

### Workflows vs direct service calls

Prefer Medusa core workflows (`@medusajs/medusa/core-flows`) for operations that need compensation/rollback (e.g. creating products, regions, shipping). Use direct module service calls (e.g. `productModuleService.createProductCategories(...)`) for simpler operations in scripts where workflow overhead isn't needed.
