# Frontend Defaults

- Read project instructions and inspect the existing component library, design tokens, and nearby UI before editing. Project-specific rules override this file.
- Reuse and compose existing components before creating a new component or primitive. Do not introduce a second UI or styling system into an established project.
- In a project with `components.json`, use the shadcn skill, inspect installed components, and check shadcn documentation or registries before writing custom UI.
- Do not keep a shadcn MCP server running globally. Invoke the shadcn CLI on demand with `pnpm dlx shadcn@latest` when a project needs it.
- For a new React project without a design system, prefer shadcn/ui. Do not replace an existing design system with shadcn without explicit approval.
- Preserve the product's visual language. Avoid generic AI defaults such as decorative eyebrows, purple gradients, interchangeable card grids, excessive rounding, meaningless statistics, and filler copy unless the brief genuinely calls for them.
- Prioritize clear information hierarchy, useful interaction states, responsive mobile behavior, keyboard access, visible focus, readable contrast, and reduced-motion support.
- Keep implementation communication concise. Do design exploration internally, surface only meaningful decisions, and verify the result in the browser when practical.

# Global Package Management Preferences

- **Preferred Package Manager**: Always use **`pnpm`** instead of `npm` or `yarn` for JavaScript/TypeScript projects (`pnpm install`, `pnpm add`, `pnpm run`, `pnpm dlx`, `pnpm create`, etc.).
- **Existing Repositories**: When working on an existing repository with an `npm` or `yarn` lockfile, suggest migrating to `pnpm` (e.g. using `pnpm import`) or check with the user before converting lockfiles.
- **Disk Optimization**: Favor `pnpm` to leverage hard links and the global content-addressable store, keeping `node_modules` footprint small across all workspaces.

# Linux Package Policy

- Prefer Ubuntu's official `apt` repositories and native `.deb` packages for system software, drivers, command-line tools, and desktop components.
- Prefer a vendor's signed APT repository when the Ubuntu repositories do not provide a suitable current version.
- Prefer Flatpak for third-party graphical applications that benefit from sandboxing or are unavailable as trustworthy native `.deb` packages.
- Avoid Snap when a well-maintained native `.deb` or Flatpak is available. Do not introduce new Snap packages without explaining why they are the best option.
- Use `pnpm` for JavaScript project dependencies. Do not install project dependencies globally through `apt`.
- Avoid `curl | sh` and similar remote installer pipelines when an APT package, signed repository, Flatpak, or verified release artifact is available. If one is necessary, inspect the script or explain the trust boundary first.
- Do not mix multiple installation methods for the same application. Before installing or migrating software, check its current package source and remove obsolete repositories only after the replacement is verified.
- Project-specific requirements override this policy when necessary; state the exception briefly.

# Docker Resource Management

- Docker is intentionally disabled at boot to conserve system resources.
- Before work that requires containers, run `docker-start`.
- When all container work for the task is finished, run `docker-stop`, unless the user explicitly asks to leave Docker running.
- Do not start Docker for tasks that do not require containers.
