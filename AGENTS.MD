# AGENTS.MD

Guidance for AI agents working in this dotfiles repository.

> Maintenance note: when the codebase/configuration changes, update this `AGENTS.MD` file (and any other `AGENTS.md`/`AGENTS.MD` files) so future AI agents can pick up the current architecture and practices quickly.

## Repository model

This repo is organized as GNU Stow packages. Each top-level directory is meant to mirror a path under `$HOME`.

- Example: `nvim/.config/nvim/init.lua` becomes `~/.config/nvim/init.lua` after `stow nvim`.
- Run Stow from the repository root (`/Users/juanse-work/dotfiles`).
- Install/update a package with `stow <package>`.
- Preview before changing symlinks with `stow -nv <package>`.
- Unstow with `stow -D <package>`.

Current packages:

- `aerospace/` → AeroSpace tiling window manager config.
- `ghostty/` → Ghostty terminal config and themes.
- `gh-dash/` → GitHub CLI dashboard config.
- `git/` → XDG Git config for Hunk as the Git pager.
- `ideavimrc/` → JetBrains IdeaVim config.
- `karabiner/` → Karabiner-Elements config and backup.
- `lazygit/` → Lazygit UI and delta pager config.
- `nvim/` → current custom Neovim config.
- `lazy-nvim/` → alternate LazyVim-based Neovim config. Do not stow this together with `nvim`; both target `~/.config/nvim`.
- `starship/` → Starship prompt config.
- `tmux/` → tmux config.
- `zsh/` → zsh startup files plus modular config under `~/.config/zsh`.

`STOW.USAGE` has the owner’s short Stow notes. `TODO` tracks future cleanup ideas.

Machine-level dependencies are declared in `Brewfile`. Use `brew bundle` (or `just install`) to install them; `just install` also installs the `dlvhdr/gh-dash` GitHub CLI extension because Homebrew Bundle does not manage `gh` extensions. `./bootstrap.sh` is a first-run helper that requires Homebrew, runs `brew bundle`, installs `gh-dash`, then runs `just check`. Use `just update` to update Homebrew metadata, upgrade installed packages/casks, sync the Brewfile, update `gh-dash`, and clean up. Shell startup files should only initialize tools when present and must not install software.

Common repo commands live in `justfile`. Bulk Stow recipes derive active top-level packages automatically and skip entries listed in `.stow-excludes` (currently `lazy-nvim` and `tmp`).

## General practices

- Preserve the Stow mirror layout. New home-directory files should live under the package path that matches the target path.
- Keep machine-level dependencies in `Brewfile`; do not add package installation to zsh startup files.
- Prefer small, focused edits. This is a personal dotfiles repo, so avoid broad rewrites unless asked.
- Do not commit machine-local secrets or overrides.
- Keep generated/local files ignored:
  - `zsh/.config/zsh/local.zsh`
  - `zsh/.zcompdump*`
- Use examples for local customization instead of tracked real local files. `zsh/.config/zsh/local.zsh.example` is the pattern.
- If changing a config that has a lockfile, update/check the lockfile intentionally and mention it.
- Maintain the existing Spanish/English mixed comments unless doing a larger cleanup requested by the owner.

## Validation commands

Use the narrowest validation possible for the package you changed:

```sh
# Show available repo recipes
just --list

# Check Stow link plan for a package
stow -nv <package>
# or
just preview <package>

# Check the normal active Stow package set
just check-stow

# Check Lua formatting/config style if editing custom Neovim Lua
stylua --check nvim/.config/nvim
# or
just check-nvim

# Open Neovim health/plugin UI manually when needed
nvim
```

Useful syntax checks:

```sh
just check-zsh
zsh -n zsh/.zshrc zsh/.zprofile zsh/.zshenv zsh/.config/zsh/*.zsh zsh/.config/zsh/tools/*.zsh
tmux source-file tmux/.tmux.conf
```

Only run commands that make sense on the current machine. Some tools may not be installed.

## Neovim: `nvim/` custom config

This is the active hand-rolled Neovim setup.

Structure:

- `nvim/.config/nvim/init.lua` contains global options, core keymaps, basic autocmds, test keymaps, and loads `require("config.lazy")`.
- `nvim/.config/nvim/lua/config/lazy.lua` bootstraps `lazy.nvim`, sets leaders, loads the `tokyonight` colorscheme, and imports `config.plugins`.
- Plugin specs live in `nvim/.config/nvim/lua/config/plugins/*.lua`.
- Filetype-local options live in `nvim/.config/nvim/after/ftplugin/*.lua`.
- Lua formatting is 2 spaces (`nvim/.config/nvim/.editorconfig`).

Important conventions:

- Leader is Space in `init.lua`. `lazy.lua` also sets `mapleader = " "`; keep leader setup before plugins load.
- Add new plugins as separate modules under `lua/config/plugins/` returning Lazy specs.
- Prefer `opts = {}` for simple plugin setup and `config = function() ... end` only when custom code/keymaps are needed.
- Keymaps should include `desc` so Which Key and Snacks can show them.
- Existing navigation style is Vim-first: arrow keys are disabled in normal mode; window navigation uses `<C-h/j/k/l>`.
- Existing plugin manager is `lazy.nvim`; `lazy-lock.json` pins plugin versions.

Main plugins/features:

- Completion: `saghen/blink.cmp` with `friendly-snippets`.
- LSP/tooling: `mason.nvim`, `mason-lspconfig.nvim`, `nvim-lspconfig`, `lazydev.nvim`.
  - Servers currently tracked in `lsp.lua`: `lua_ls`, `pyright`, `terraformls`, `rust_analyzer`.
- Formatting: `conform.nvim` on `BufWritePre` with `stylua`, `isort`, `black`.
- Diagnostics/format sources: `none-ls.nvim` with `stylua` and `pylint`.
- Linting: `nvim-lint`, currently `luacheck` for Lua.
- Testing: `neotest` + `neotest-python`; test keymaps are in `init.lua` under `<leader>t*`.
- Debugging: `nvim-dap`, `mason-nvim-dap`, `nvim-dap-python`, `nvim-dap-ui`; keymaps under `<leader>d*`.
- Navigation/UI: `snacks.nvim`, `oil.nvim`, `mini.nvim`, `which-key.nvim`, `gitsigns.nvim`, `nvim-treesitter`.
- Telescope is intentionally disabled by returning `{}` in `telescope.lua`; Snacks picker is the current picker.

When adding language support:

1. Add the LSP server to the `servers` table in `lsp.lua` if it should be managed by Mason.
2. Add Treesitter parsers in `treesiter.lua` when useful.
3. Add formatters to Conform and linters to `nvim-lint` only if the corresponding CLI is expected to exist.
4. Avoid duplicate formatters/diagnostics between `conform.nvim`, `none-ls.nvim`, and LSP unless intentional.

## Neovim: `lazy-nvim/` alternate config

This is a LazyVim starter/alternate setup, not the main custom config.

- It also targets `~/.config/nvim`, so do not apply with `nvim/` at the same time.
- `lua/config/lazy.lua` imports LazyVim plus extras for DAP, tests, and Python.
- Custom plugins are in `lazy-nvim/.config/nvim/lua/plugins/`.
- Current customizations include OneDark Cool, Oil, Which Key classic preset, and Obsidian integration for `~/university/zettelkasten`.

If editing this package, follow LazyVim conventions (`opts` overrides, extras imports, plugin specs under `lua/plugins/`).

## zsh package

Entrypoints:

- `zsh/.zshenv` is intentionally minimal because zsh sources it for every invocation.
- `zsh/.zprofile` handles login-shell setup, especially Homebrew `shellenv` for Apple Silicon and Intel paths.
- `zsh/.zshrc` is the interactive entrypoint. It sources modular files from `~/.config/zsh`.

Module order in `.zshrc`:

1. `plugins.zsh` — Oh My Zsh setup, plugins `git kubectl`, no theme by default because Starship owns the prompt.
2. `env.zsh` — shared environment (`MANPAGER`, `PYENV_ROOT`).
3. `path.zsh` — path additions using zsh arrays and `typeset -U path PATH`.
4. `bindings.zsh` — key bindings, currently binds `^f` to `tmux-sessionizer` if available.
5. Tool integrations: `fzf`, `zoxide`, `pyenv`, `starship`.
6. `local.zsh` — machine-local overrides, ignored by git.

Practices:

- Put shared, portable changes in the appropriate module.
- Put machine-specific aliases/secrets/PATH entries in `local.zsh` only; update `local.zsh.example` if the pattern should be documented.
- Guard optional tools with `command -v` or file checks, as existing modules do.
- Keep `.zshenv` minimal.

## tmux package

`tmux/.tmux.conf` uses:

- zsh as default shell.
- vi copy mode.
- macOS clipboard via `pbcopy`.
- mouse support.
- 1-based window/pane indexes.
- Vim-like pane navigation with prefix + `h/j/k/l`.
- TPM plugin manager (`tmux-plugins/tpm`) initialized at the bottom.
- Custom OneDark Cool status theme.

Keep `run '~/.tmux/plugins/tpm/tpm'` at the very bottom.

## Starship package

`starship/.config/starship.toml` defines a two-line prompt with Nerd Font symbols and modules for git, Kubernetes, Terraform, AWS, Docker, Go, Rust, Python, Node.js, Buf, and command duration.

- Kubernetes is enabled and has a context alias/style for `production`.
- This repo assumes Nerd Fonts are available.

## Git, Lazygit, and GitHub dashboard packages

`git/.config/git/config` configures `hunk pager` as the default Git pager, so `git diff`, `git show`, and the `git hdiff`/`git hshow` aliases open in Hunk.

`lazygit/.config/lazygit/config.yml` uses a OneDark Cool-inspired palette and configures Lazygit paging through `delta --dark --paging=never --syntax-theme=OneHalfDark`. `zsh/.config/zsh/env.zsh` sets `XDG_CONFIG_HOME=$HOME/.config` so Lazygit uses the tracked XDG config path on macOS.

`gh-dash/.config/gh-dash/config.yml` defines broad personal PR/issue sections and adds an `H` keybinding that pipes `gh pr diff` into `hunk patch -`. `gh-dash` itself is installed as a GitHub CLI extension by `just install-gh-dash`; it is not a Homebrew formula.

## Ghostty package

`ghostty/.config/ghostty/config` uses:

- Theme: `onedark-cool.conf` from the tracked `themes/` directory.
- Font: JetBrains Mono, size 16.
- No window decoration and zero padding.

If adding themes, place them under `ghostty/.config/ghostty/themes/` and reference them by filename from `config`.

## AeroSpace package

`aerospace/.config/aerospace/aerospace.toml` configures macOS tiling:

- Starts at login.
- Tiling defaults with explicit gaps.
- Mouse follows focused monitor/window lazily.
- Main bindings use `alt` for focus/workspace and `alt-shift` for moving windows.
- Service mode is `alt-shift-semicolon`.
- App rules move common apps to named workspaces (JetBrains to `P`, Spotify to `M`, terminal to `T`, browser to `A`, etc.).

When editing bindings or rules, preserve the existing mnemonic workspace scheme unless asked.

## IdeaVim package

`ideavimrc/.ideavimrc` configures JetBrains IdeaVim:

- `scrolloff=5`, incremental search, `Q` mapped to `gq`.
- Plugins: highlighted yank and commentary.
- Enables `easymotion` and `NERDTree`.

## Karabiner package

`karabiner/.config/karabiner/karabiner.json` is the active Karabiner-Elements config. The `automatic_backups/` directory contains a generated backup snapshot.

Be careful editing Karabiner JSON by hand. Prefer small JSON-preserving edits and validate syntax if possible.
