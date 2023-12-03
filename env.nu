#!/usr/bin/env nu

export-env {
  let esep_list_conterter = {
    from_string = { |s| $s | split row (char esep) }
    to_string = { |s| $s | str join (char esep) }
  }

  $env.ENV_CONVERSIONS = {
      "PATH": {
          from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
          to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
      }
      "Path": {
          from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
          to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
      }
  }

}

# Directory | linux           | mac                            |  windows
# Config    | ~/.config/      | ~/Library/Application/         | %APPDATA%
# Cache     | ~/.cache/       | ~/Library/Caches/              | %LOCALAPPDATA
# Data      | ~/.local/share/ | ~/Library/Application Support/ | %APPDATA%
# Runtime   | /run/user/$UID  | /var/folders                   | %TEMP%

export-env { load-env {
  XDG_DATA_HOME: ($env.HOME | path join ".local" "share")
  XDG_CONFIG_HOME: ($env.HOME | path join ".config")
  XDG_STATE_HOME: ($env.HOME | path join ".local" "state")
  XDG_CACHE_HOME: ($env.HOME | path join ".cache")
}}

export-env { load-env {
  BROWSER: "firefox"
  DEBUGINFOD_URLS: "https://debuginfod.archlinux.org/"
  CARGO_TARGET_DIR: "~/.cargo/target"
  MOZ_ENABLE_WAYLAND: 1
  EDITOR: "nvim"
  VISUAL: "nvim"
  PAGER: "less"
  SHELL: "nu"
  HOSTNAME:  (hostname | split row '.' | first | str trim)
  SHOW_USER: true
  SSH_AUTH_SOCK: $"($env.XDG_RUNTIME_DIR)/ssh-agent.socket"
  SSH_AGENT_TIMEOUT: 300
  SSH_KEYS_HOME: ($env.HOME | path join ".ssh" "keys")
}}

export-env { load-env {
  SQLITE_HISTORY: ($env.XDG_CACHE_HOME | path join "sqlite_history")
}}

$env.TERMINFO_DIRS = (
  [
    ($env.XDG_DATA_HOME | path join 'terminfo')
    "/usr/share/terminfo"
  ] | str join ':'
)

$env.PATH = ($env.PATH | split row (char esep) | prepend '~/.cargo/bin/' | prepend '~/.local/bin/')

$env.NU_LIB_DIRS = [
    ($nu.default-config-dir)
    ($nu.default-config-dir | path join "scripts")
    ($nu.default-config-dir | path join "modules")
]

$env.SHELL = $nu.current-exe
