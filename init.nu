# ~/.config/nushell/init.nu
#
# Init module that exports commands and environment variables wanted at startup

# commands
export def egd [...rest] {
    with-env [GIT_EXTERNAL_DIFF 'difft'] { git diff $rest }
}

# we need to export the env we create witk load-env
# because we are `use`-ing here and not `source`-ing this file
export-env {
    load-env {
        BROWSER: "firefox"
        CARGO_TARGET_DIR: "~/.cargo/target"
        EDITOR: "nvim"
        VISUAL: "nvim"
        PAGER: "less"
        SHELL: "nu"
        HOSTNAME:  (hostname | split row '.' | first | str trim)
        SHOW_USER: true
    }
}
