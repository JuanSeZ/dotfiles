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
- `agenmux/` → agenmux (tmux AI agent monitor plugin) `config.toml`. tmux only; Rex uses its own activity instead.
- `bin/` → personal scripts in `~/.local/bin` (`tmux-sessionizer`, `rex-sessionizer`, `rex-activity`, `rex-popup`, `rex-claude-status`, plus `rex-common.sh`, which the first three Rex scripts source for PATH, `$rex` and `app_client`; `rex-claude-status` stays standalone because it runs as a Claude hook). `~/.local/bin` is a real directory with other tools, so Stow links these files individually.
- `ghostty/` → Ghostty terminal config and themes.
- `gh-dash/` → GitHub CLI dashboard config.
- `git/` → XDG Git config for Hunk as the Git pager.
- `ideavimrc/` → JetBrains IdeaVim config.
- `karabiner/` → Karabiner-Elements config and backup.
- `lazygit/` → Lazygit UI and delta pager config.
- `nvim/` → current custom Neovim config.
- `lazy-nvim/` → alternate LazyVim-based Neovim config. Do not stow this together with `nvim`; both target `~/.config/nvim`.
- `rex/` → Rex terminal multiplexer `init.lua` (key bindings migrated from tmux).
- `starship/` → Starship prompt config.
- `television/` → television (`tv`) fuzzy finder: the `rex-sessions` and `rex-activity` cable channels used by `rex-sessionizer` and `rex-activity`. The `config.toml` tv writes on first run lands here through the stowed directory and is gitignored, so tv's defaults stay current.
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
4. `bindings.zsh` — key bindings, currently binds `^f` to `rex-sessionizer` inside Rex (`$REX_SESSION` set, `$TMUX` unset) and to `tmux-sessionizer` otherwise, if available.
5. Tool integrations: `fzf`, `zoxide`, `pyenv`, `starship`.
6. `local.zsh` — machine-local overrides, ignored by git.

Practices:

- Put shared, portable changes in the appropriate module.
- Put machine-specific aliases/secrets/PATH entries in `local.zsh` only; update `local.zsh.example` if the pattern should be documented.
- `local.zsh.example` includes a `kh` alias example for a local homelab kubeconfig; keep the active alias in ignored `local.zsh`.
- Guard optional tools with `command -v` or file checks, as existing modules do.
- Keep `.zshenv` minimal.

## tmux package

`tmux/.tmux.conf` uses:

- zsh as default shell.
- vi copy mode.
- macOS clipboard via `pbcopy`.
- mouse support.
- 1-based window/pane indexes.
- Vim-like pane navigation with prefix + `h/j/k/l`, and resize (5 cells) with prefix + `Ctrl-h/j/k/l`. The first press switches the client into a sticky `resize` key table where `Ctrl-h/j/k/l` keep resizing with no timeout; any other key falls back to the root table and acts normally. `status-left` shows `RESIZE` while `#{client_key_table}` is `resize`. The default `C-arrow`/`M-arrow` resize keys don't reach tmux on this Mac (macOS Spaces/Mission Control and Ghostty's `alt+arrow` word-jump bindings take them). Keep prefix + `L` as `switch-client -l` (last session); the owner uses it heavily.
- TPM plugin manager (`tmux-plugins/tpm`) initialized at the bottom.
- `focus-events on` (agenmux notification focus detection, Neovim focus events).
- Custom OneDark Cool status theme.
- `snirt/agenmux` plugin, pinned to a release tag (`@plugin 'snirt/agenmux#vX.Y.Z'`) so TPM installs the prebuilt, checksum-verified Rust engine instead of building from source. `prefix + A` opens the sidebar, `prefix + e` the popup. `status-right` contains `#{agenmux}`, which the plugin rewrites into its agent-count segment when it loads, so it must stay in `status-right` before the TPM `run` line.

Keep `run '~/.tmux/plugins/tpm/tpm'` at the very bottom.

## agenmux package

`agenmux/.config/agenmux/config.toml` holds agenmux settings (display, behavior, theme, keys). Launcher keys and the plugin pin live in `tmux/.tmux.conf`.

- `behavior.auto_update = false`: upgrades are intentional. Upgrade with `U` (version picker) in the sidebar, then bump the tag in the `@plugin` line so new machines install the same version.
- agenmux saves edits from its settings view (`s`) through symlinks, so in-app changes land in the tracked file. Review them before committing.
- Detection reads the screen (no agent hooks), so nothing needs adding to `~/.claude` or `~/.codex`. Custom agent rules go in `~/.config/agenmux/agents/*.conf`, which is inside this package once stowed.
- Runtime state is outside the repo: `~/.local/state/agenmux/` (daemon log, layout snapshots), and macOS notifications go through `~/Applications/Agenmux.app`.
- Notifications (with the hardcoded macOS `Glass` sound) fire when an agent finishes or blocks while its pane isn't focused, and only while an agenmux sidebar or popup is open. They need macOS permission (System Settings → Notifications → agenmux); `~/Applications/Agenmux.app/Contents/MacOS/agenmux-notifier --setup` requests it and sends a test notification once allowed.

## Rex package

`rex/.config/rex/init.lua` is the Rex config (Lua, `rex.bind`/`rex.mode`). It mirrors the tmux key bindings under the same `ctrl+b` prefix:

- `ctrl+b>h/j/k/l` focus panes; `ctrl+b>ctrl+h/j/k/l` resize by 5; `ctrl+b>r` reloads the config; `ctrl+b>ctrl+b` sends a literal `ctrl+b` to the program.
- `ctrl+b>[` is copy mode: `rex/.config/rex/bin/rex-copy-mode` captures the block's scrollback (`rex capture`) and opens it in Neovim (read-only, `clipboard=unnamedplus`, `q` quits) on a full-window floating layer. Rex has no native vi copy mode, and the owner uses this heavily. Needs `jq` (in `Brewfile`).
- Sessionizer: `ctrl+b>f` (Rex action `sessionizer`, works over any program) and `ctrl+f` at a zsh prompt (a zle widget) both run `bin/.local/bin/rex-sessionizer`. It opens a centred floating layer (`session.new_layer`) running `tv rex-sessions` (`television/.config/television/cable/rex-sessions.toml`), which lists open sessions first, then the same project directories as `tmux-sessionizer`, minus those with a session of the same name. The preview shows a session's screen (`rex capture`) or a folder's git status and listing. Enter switches (`rex new <name> -c <dir>` first for a folder, then `rex -C <app client> do goto_session`, init.lua's action that also notes the session left for `ctrl+b>shift+l`), ctrl+d kills a session (never the current one), ctrl+s cycles All/Sessions/Folders. The switch needs Remote Control on (Rex Settings > Rex Server). The same script also serves the channel's source, preview and kill commands (`--list`, `--preview`, `--kill`).
- Activity picker: `ctrl+b>a` (Rex action `activity`) runs `bin/.local/bin/rex-activity`, a `tv rex-activity` popup listing every pane whose program has a status, most urgent first (blocked, error, done, working, idle). Each line reads `<state in words> <app> <session › tab> <message or title> · <age>`, e.g. `Needs you  Claude  hidden-marsh › tab 3  Permission to use Bash · 2m ago`, most urgent first, then most recent. Statuses come from Rex's Program Status Protocol (OSC 7501, gathered in one `rex do -e` Lua call). Codex reports OSC 7501 itself; Claude Code reports it through `bin/.local/bin/rex-claude-status`, run by hooks in `~/.claude/settings.json` (not tracked here): SessionStart idle, UserPromptSubmit and PostToolUse working, PermissionRequest and PreToolUse on AskUserQuestion blocked, Notification blocked for permission/elicitation types only, Stop done, StopFailure error, SessionEnd clear. It writes to Claude's tty, only when `$REX_SESSION` is set, and never prints or fails. Preview is the pane's screen; Enter runs init.lua's `goto_block` (focus the pane, then switch session via `goto_session`), across sessions.
- `bin/.local/bin/rex-popup SESSION BLOCK LABEL COMMAND...` opens the centred floating layer both pickers use.
- tmux defaults: `ctrl+b>c` new window in the current session, starting in the focused pane's folder (`new_window`, via `rex.session.new_window` with the shell block's `cwd` option, so it can't land in another session); `ctrl+b>n`/`p` next/previous window of the current session, wrapping (`next_window`/`previous_window`; Rex's `client.tab.next` walks every session's tabs and `session.focus_next_window` stops at the ends), `ctrl+b>%` and `ctrl+b>|` split right, `ctrl+b>"` splits below, `ctrl+b>z` toggles zoom, `ctrl+b>x` closes the pane (`pane.close`).
- `ctrl+b>;` is last pane (tmux `prefix + ;`) and `ctrl+b>tab` is last window (tmux `prefix + l`, whose key here focuses the pane to the right). Rex keeps no focus history, so the ctrl+b keys note it through `note_focus`/`note_in`: panes per window in `~/.local/state/rex-last-pane`, windows per session in `~/.local/state/rex-last-window` (`key<TAB>current<TAB>previous`, most recent key first, capped at 50). `ctrl+b>h/j/k/l` and the split keys go through the `focus_pane`/`split_pane` actions for this; `n`/`p`/`c`, `last_pane`, `last_window` and `goto_block` note too. Each key notes where you are when you press it, so a switch made with the mouse or Rex's own keys (cmd+1…9, left alone because their default binding uses key codes) is caught at the next ctrl+b key.
- `ctrl+b>shift+l` is last session (tmux `prefix + L`). Rex keeps no session history, so `init.lua` notes the session each keyboard switch leaves in `~/.local/state/rex-last-session` (line 1 current, line 2 previous): `last_session`, `goto_session` (which `rex-sessionizer` switches through) and `session_picker` (the `shift+cmd+k` wrapper around `session.switch`). Switches made with the mouse are not noted, so after one the key returns to the last session a key switch left.
- `cmd+k` clears the terminal (owner's choice, as in Ghostty); the session picker (Rex's default on `cmd+k`) moves to `shift+cmd+k`.
- `ctrl+b>ctrl+h/j/k/l` resizes by 5 per press. tmux's sticky `resize` table is not copied: a Rex mode stays active until escape (and `once` may only count keys the mode binds), so it would keep `ctrl+h/j/k/l` from Neovim's window navigation.
- `ctrl+b>shift+a` toggles Rex's own sidebar (`client.sidebar.toggle`), where tmux `prefix + A` toggled agenmux's.
- No agenmux in Rex: Rex's own activity (tab spinners, sidebar, notifications, the `ctrl+b>a` picker) covers agent status now that Claude reports it through hooks. agenmux's upstream Rex backend (`poc/rex-multiplexer`, snirt/agenmux#231) was tried and removed.

Validate with `REX_CONFIG=~/.config/rex/init.lua <rex> config check`, where `<rex>` is the `rex` binary inside the Rex Server app bundle, then choose Reload Config in Rex (or run `<rex> config reload` against the server socket). The status bar theme, tmux options and TPM have no Rex counterpart, so `tmux/` stays the source for those.

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
