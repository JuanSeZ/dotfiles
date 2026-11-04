# Shared by rex-sessionizer, rex-activity and rex-popup, which source it from
# their own directory. Not a command: it only sets things up.

# Rex actions and popups start with a bare PATH
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
rex="${REX_BIN_DIR:-$HOME/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS}/rex"

# The app window showing this pane's session, else any app window
app_client() {
  "$rex" client ls --json | jq -r --arg s "${REX_SESSION:-}" '
    [.clients[] | select(.info.kind? == "app")]
    | (map(select((.session_ids // []) | index($s))) + .)[0].client_id // empty'
}
