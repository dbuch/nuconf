use prompt.nu create_left_prompt
use prompt.nu create_right_prompt

# Use nushell functions to define your right and left prompt
$env.PROMPT_COMMAND = {|| create_left_prompt }
$env.PROMPT_COMMAND_RIGHT = {|| create_right_prompt }

# The prompt indicators are environmental variables that represent
# the state of the prompt
$env.PROMPT_INDICATOR = {|| " ❯ " }
$env.PROMPT_INDICATOR_VI_INSERT = {|| " ❯ " }
$env.PROMPT_INDICATOR_VI_NORMAL = {|| " ❮ " }
$env.PROMPT_MULTILINE_INDICATOR = {|| "::: " }

export-env {
    load-env {
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
    }
}

export def la [path?: string = ""] {
  ls -l $path | sort-by type | select mode name size modified
}
