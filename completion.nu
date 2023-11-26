$env.config.completions.external = {
  enable: true
  max_results: 100
}

# TODO: refactor
$env.config.completions.external.completer = {|spans: list<string>|
    carapace $spans.0 nushell $spans
    | from json
    | if ($in | default [] | where value =~ '^-.*ERR$' | is-empty) { $in } else { null }
}
