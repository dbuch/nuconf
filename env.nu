#!/usr/bin/env nu

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

$env.SSH_AUTH_SOCK = ($env.XDG_RUNTIME_DIR | path join 'ssh-agent.socket')
$env.PATH = ($env.PATH | split row (char esep) | prepend '~/.cargo/bin/' | prepend '~/.local/bin/')

# Directories to search for scripts when calling source or use
$env.NU_LIB_DIRS = [
    ($nu.default-config-dir)
    ($nu.default-config-dir | path join 'scripts')
    ($nu.default-config-dir | path join 'modules')
    ($nu.default-config-dir | path join 'hooks')
]
