-- Rex config, migrated from ~/.tmux.conf and ~/.config/ghostty/config

-- cmd+k clears the terminal (as in Ghostty); the session picker moves to shift+cmd+k
rex.bind("cmd+k", "com.superlogical.terminal.clear")
rex.bind("shift+cmd+k", "session_picker")

-- tmux prefix ctrl+b: press it twice to send ctrl+b to the program
rex.bind("ctrl+b>ctrl+b", "pane.send_key", { key = "ctrl+b" })

-- tmux prefix + r: reload the config
rex.bind("ctrl+b>r", "client.config.reload")

-- Last pane (tmux prefix + ;) and last window (tmux prefix + l, on tab here).
-- Rex keeps no focus history, so the ctrl+b keys below note it: panes per
-- window, windows per session. Each file holds "key<TAB>current<TAB>previous"
-- lines, most recent key first.
local pane_history = os.getenv("HOME") .. "/.local/state/rex-last-pane"
local window_history = os.getenv("HOME") .. "/.local/state/rex-last-window"

-- Notes value as key's current one in file; returns the one before it
local function note_in(file, key, value)
  local entries, entry = {}, nil
  local f = io.open(file)
  if f then
    for line in f:lines() do
      local k, current, previous = line:match("^([^\t]+)\t([^\t]*)\t([^\t]*)$")
      if k == key then entry = { k, current, previous }
      elseif k then table.insert(entries, { k, current, previous }) end
    end
    f:close()
  end
  entry = entry or { key, "", "" }
  if entry[2] ~= value then entry = { key, value, entry[2] } end
  table.insert(entries, 1, entry)
  f = io.open(file, "w")
  if f then
    for i = 1, math.min(#entries, 50) do f:write(table.concat(entries[i], "\t"), "\n") end
    f:close()
  end
  return entry[3]
end

-- The window holding block in view, and that window's set of blocks
local function window_of(view, block)
  for _, w in ipairs(view and view.windows or {}) do
    local blocks = {}
    for _, layer in ipairs(w.layers or {}) do
      for _, b in ipairs(layer.blocks or {}) do blocks[b.block_id] = true end
    end
    if block and blocks[block] then return w.window_id, blocks end
  end
end

-- Notes the focused pane and the window holding it, which is the tab the app
-- shows (the server's active window can be another). Returns the session's
-- view, that window, its set of blocks, the pane before and the window before.
local function note_focus(ctx)
  local view = rex.session.view{}
  local window, blocks = window_of(view, ctx.block_id)
  if not window then return view end
  return view, window, blocks,
    note_in(pane_history, window, ctx.block_id),
    note_in(window_history, ctx.session_id, window)
end

-- Shows window in the app. session.focus_window and session.new_window only
-- move the server's active window; the app keeps showing its own tab.
local function show_window(session, window)
  rex.client.queue("session.select", { session_id = session, window_id = window })
end

rex.action{
  name = "focus_pane",
  title = "Focus Pane (noting the last one)",
  args = { direction = "string" },
  run = function(ctx, args)
    note_focus(ctx)
    rex.client.queue("pane.focus", { direction = args.direction })
  end,
}
rex.action{
  name = "split_pane",
  title = "Split Pane (noting the last one)",
  args = { direction = "string" },
  run = function(ctx, args)
    note_focus(ctx)
    rex.client.queue("pane.split", { direction = args.direction })
  end,
}
rex.action{
  name = "last_pane",
  title = "Last Pane",
  run = function(ctx)
    local _, window, blocks, previous = note_focus(ctx)
    if blocks and previous and previous ~= "" and blocks[previous] then
      rex.session.focus_block{ block_id = previous }
      note_in(pane_history, window, previous)
    end
  end,
}
rex.bind("ctrl+b>;", "last_pane")

-- tmux prefix + h/j/k/l: focus the pane in that direction
rex.bind("ctrl+b>h", "focus_pane", { direction = "left" })
rex.bind("ctrl+b>j", "focus_pane", { direction = "down" })
rex.bind("ctrl+b>k", "focus_pane", { direction = "up" })
rex.bind("ctrl+b>l", "focus_pane", { direction = "right" })

-- tmux prefix + n/p: next/previous window of this session (client.tab.next
-- would walk every session's tabs), wrapping around at the ends as tmux does
-- (Rex's focus_next_window stops there)
local function cycle_window(ctx, step)
  local view, current = note_focus(ctx)
  local windows = view and view.windows or {}
  for i, w in ipairs(windows) do
    if w.window_id == current then
      show_window(ctx.session_id, windows[(i - 1 + step) % #windows + 1].window_id)
      return
    end
  end
end
rex.action{
  name = "next_window",
  title = "Next Window in Session",
  run = function(ctx) cycle_window(ctx, 1) end,
}
rex.action{
  name = "previous_window",
  title = "Previous Window in Session",
  run = function(ctx) cycle_window(ctx, -1) end,
}
rex.bind("ctrl+b>n", "next_window")
rex.bind("ctrl+b>p", "previous_window")

rex.action{
  name = "last_window",
  title = "Last Window",
  run = function(ctx)
    local view, _, _, _, previous = note_focus(ctx)
    for _, w in ipairs(view and view.windows or {}) do
      if w.window_id == previous then
        show_window(ctx.session_id, previous)
        note_in(window_history, ctx.session_id, previous)
        return
      end
    end
  end,
}
rex.bind("ctrl+b>tab", "last_window")

-- tmux prefix + c: a new window in this session, starting in the pane's folder
local function pane_dir(ctx)
  if not ctx.block_id then return "" end
  local r = rex.block.call("com.superlogical.terminal", "pwd", { session_id = ctx.session_id, block_id = ctx.block_id })
  -- "file://host/Users/me/my%20dir" -> "/Users/me/my dir"
  local path = (r and r.pwd or ""):gsub("^file://[^/]*", "")
  return (path:gsub("%%(%x%x)", function(h) return string.char(tonumber(h, 16)) end))
end
rex.action{
  name = "new_window",
  title = "New Window in Session",
  run = function(ctx)
    note_focus(ctx)
    local w, err = rex.session.new_window{
      layout = rex.layout.block{ flavor = "com.superlogical.terminal.shell", options = { cwd = pane_dir(ctx) } },
    }
    if err ~= nil then error(err, 0) end
    show_window(ctx.session_id, w.window_id)
  end,
}
rex.bind("ctrl+b>c", "new_window")

-- tmux prefix + % (and |) split side by side, " splits below, z zooms the
-- pane, x closes it
rex.bind("ctrl+b>shift+5", "split_pane", { direction = "right" })
rex.bind("ctrl+b>shift+\\", "split_pane", { direction = "right" })
rex.bind("ctrl+b>shift+'", "split_pane", { direction = "down" })
rex.bind("ctrl+b>z", "pane.zoom")
rex.bind("ctrl+b>x", "pane.close")

-- Last session (tmux prefix + L, on shift+tab here). Rex keeps no session history, so each switch
-- made from a key notes the session it leaves, in a file that survives
-- reloads: line 1 is the current session, line 2 the one before it.
local history = os.getenv("HOME") .. "/.local/state/rex-last-session"

local function read_history()
  local f = io.open(history)
  if not f then return nil, nil end
  local current, previous = f:read("*l"), f:read("*l")
  f:close()
  return current, previous
end

local function note_session(session)
  local current = read_history()
  if session == nil or session == "" or session == current then return end
  local f = io.open(history, "w")
  if f then
    f:write(session, "\n", current or "", "\n")
    f:close()
  end
end

local function session_exists(session)
  local list = rex.call("session.list", {})
  for _, s in ipairs(list and list.sessions or {}) do
    if s.session_id == session then return true end
  end
  return false
end

-- window, if given, is the tab to show in session
local function goto_session(from, session, window)
  note_session(from)
  note_session(session)
  rex.client.queue("session.select", { session_id = session, window_id = window })
end

rex.action{
  name = "last_session",
  title = "Last Session",
  run = function(ctx)
    note_session(ctx.session_id)
    local _, previous = read_history()
    if previous and previous ~= "" and session_exists(previous) then
      goto_session(ctx.session_id, previous)
    end
  end,
}
-- rex-sessionizer switches through this, so its switches are noted too
rex.action{
  name = "goto_session",
  title = "Go to Session (noting the last one)",
  args = { session_id = "string", from = "string?" },
  run = function(ctx, args)
    goto_session(args.from or ctx.session_id, args.session_id)
  end,
}
-- rex-activity jumps through this: the pane's window becomes active in its
-- session, then the app goes to that session
rex.action{
  name = "goto_block",
  title = "Go to Pane (noting the last session)",
  args = { session_id = "string", block_id = "string", from = "string?" },
  run = function(ctx, args)
    local view = rex.call("session.view", { session_id = args.session_id })
    local window = window_of(view, args.block_id)
    if not window then error("no window holds " .. args.block_id, 0) end
    -- the window left (as the server last saw it) and the one reached, for ctrl+b>tab
    if view.active_window_id then note_in(window_history, args.session_id, view.active_window_id) end
    note_in(window_history, args.session_id, window)
    local _, err = rex.call("session.focus_block", { session_id = args.session_id, block_id = args.block_id })
    if err ~= nil then error(err, 0) end
    goto_session(args.from or ctx.session_id, args.session_id, window)
  end,
}
-- Rex's session picker, noting the session it leaves
rex.action{
  name = "session_picker",
  title = "Change Session (noting the last one)",
  run = function(ctx)
    note_session(ctx.session_id)
    rex.client.queue("session.switch")
  end,
}
-- shift+tab, next to tab's last window: shift+l starts resizing right
rex.bind("ctrl+b>shift+tab", "last_session")

-- Sticky resize: prefix + shift+h/j/k/l resizes the pane by 5 and stays
-- resizing, so h/j/k/l (shift or not) keep going without the prefix. The mode
-- is exclusive: every other key does nothing until esc, so nothing typed while
-- resizing reaches the terminal.
rex.mode("resize", { exclusive = true })
rex.action{
  name = "resize_sticky",
  title = "Resize Pane and Keep Resizing",
  args = { direction = "string" },
  run = function(_, args)
    rex.client.queue("pane.resize", { amount = 5, direction = args.direction })
    rex.client.queue("client.mode.enter", { name = "resize" })
  end,
}
for key, direction in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
  rex.bind("ctrl+b>shift+" .. key, "resize_sticky", { direction = direction })
  rex.bind("resize/" .. key, "pane.resize", { amount = 5, direction = direction })
  rex.bind("resize/shift+" .. key, "pane.resize", { amount = 5, direction = direction })
end
rex.bind("resize/esc", "client.mode.exit")

-- Copy mode (tmux prefix + [), see rex-copy-mode
local copy_mode = os.getenv("HOME") .. "/.config/rex/bin/rex-copy-mode"
rex.action{
  name = "copy_mode",
  title = "Copy mode (scrollback in Neovim)",
  run = function(ctx)
    assert(rex.exec.start({ copy_mode, ctx.session_id, ctx.block_id }, { detach = true }))
  end,
}
rex.bind("ctrl+b>[", "copy_mode")

-- Sessionizer (zsh ctrl+f opens it too): a television popup over open sessions
-- and project folders, from rex-sessionizer in the dotfiles bin package.
local sessionizer = os.getenv("HOME") .. "/.local/bin/rex-sessionizer"
rex.action{
  name = "sessionizer",
  title = "Sessionizer",
  run = function(ctx)
    assert(rex.exec.start({ sessionizer, "--popup", ctx.session_id, ctx.block_id or "", ctx.client_id or "" }, { detach = true }))
  end,
}
rex.bind("ctrl+b>f", "sessionizer")

-- Activity picker: a television popup over every pane whose program has a
-- status in Rex (Codex reports one, Claude through hooks), from rex-activity.
local activity = os.getenv("HOME") .. "/.local/bin/rex-activity"
rex.action{
  name = "activity",
  title = "Activity",
  run = function(ctx)
    assert(rex.exec.start({ activity, "--popup", ctx.session_id, ctx.block_id or "", ctx.client_id or "" }, { detach = true }))
  end,
}
rex.bind("ctrl+b>a", "activity")

-- Rex's sidebar (sessions and activity), where tmux prefix + A toggled agenmux's
rex.bind("ctrl+b>shift+a", "client.sidebar.toggle")
