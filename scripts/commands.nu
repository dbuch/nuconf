def "cargo targets" [type: string] {
  let result = do -i { ^cargo metadata --format-version=1 --offline --no-deps | complete }
  if $result.exit_code != 0 {
    error make -u { msg: "No cargo manifest in current path" }
  }

  let targets = ($result.stdout |
                 from json |
                 get packages.targets |
                 flatten |
                 where ($type in $it.kind))

  if ($targets | is-empty) {
    error make -u { msg: $"Cargo manifest has no ($type)s" }
  } else {
    $targets | get name
  }
}

export def "cargo bins" [] { cargo targets bin }
export def "cargo examples" [] { cargo targets example }

export def "cargo packages" [] {
  let metadata = (^cargo metadata --format-version=1 --offline --no-deps)
  if $metadata == '' {
    []
  } else {
    $metadata | from json | get workspace_members | split column ' ' | get column1
  }
}


export def nope [] {
  each { |it| $it == false }
}

export def repo-structured [] {
  let repo_toplevel = (do --ignore-errors { git rev-parse --show-toplevel })
  let in_git_repo = ($repo_toplevel | is-empty | nope)

  let status = (if $in_git_repo {
    git --no-optional-locks status --porcelain=2 --branch | lines
  } else {
    []
  })

  let on_named_branch = (if $in_git_repo {
    $status
    | where ($it | str starts-with '# branch.head')
    | first
    | str contains '(detached)'
    | nope
  } else {
    false
  })

  let branch_name = (if $on_named_branch {
    $status
    | where ($it | str starts-with '# branch.head')
    | split column ' ' col1 col2 branch
    | get branch
    | first
  } else {
    ''
  })

  let commit_hash = (if $in_git_repo {
    $status
    | where ($it | str starts-with '# branch.oid')
    | split column ' ' col1 col2 full_hash
    | get full_hash
    | first
    | str substring [0 7]
  } else {
    ''
  })

  let tracking_upstream_branch = (if $in_git_repo {
    $status
    | where ($it | str starts-with '# branch.upstream')
    | str collect
    | is-empty
    | nope
  } else {
    false
  })

  let upstream_exists_on_remote = (if $in_git_repo {
    $status
    | where ($it | str starts-with '# branch.ab')
    | str collect
    | is-empty
    | nope
  } else {
    false
  })

  let ahead_behind_table = (if $upstream_exists_on_remote {
    $status
    | where ($it | str starts-with '# branch.ab')
    | split column ' ' col1 col2 ahead behind
  } else {
    [[]]
  })

  let commits_ahead = (if $upstream_exists_on_remote {
    $ahead_behind_table
    | get ahead
    | first
    | into int
  } else {
    0
  })

  let commits_behind = (if $upstream_exists_on_remote {
    $ahead_behind_table
    | get behind
    | first
    | into int
    | math abs
  } else {
    0
  })

  let has_staging_or_worktree_changes = (if $in_git_repo {
    $status
    | where ($it | str starts-with '1') || ($it | str starts-with '2')
    | str collect
    | is-empty
    | nope
  } else {
    false
  })

  let has_untracked_files = (if $in_git_repo {
    $status
    | where ($it | str starts-with '?')
    | str collect
    | is-empty
    | nope
  } else {
    false
  })

  let has_unresolved_merge_conflicts = (if $in_git_repo {
    $status
    | where ($it | str starts-with 'u')
    | str collect
    | is-empty
    | nope
  } else {
    false
  })

  let staging_worktree_table = (if $has_staging_or_worktree_changes {
    $status
    | where ($it | str starts-with '1') || ($it | str starts-with '2')
    | split column ' '
    | get column2
    | split column '' staging worktree --collapse-empty
  } else {
    [[]]
  })

  let staging_added_count = (if $has_staging_or_worktree_changes {
    $staging_worktree_table
    | where staging == 'A'
    | length
  } else {
    0
  })

  let staging_modified_count = (if $has_staging_or_worktree_changes {
    $staging_worktree_table
    | where staging in ['M', 'R']
    | length
  } else {
    0
  })

  let staging_deleted_count = (if $has_staging_or_worktree_changes {
    $staging_worktree_table
    | where staging == 'D'
    | length
  } else {
    0
  })

  let untracked_count = (if $has_untracked_files {
    $status
    | where ($it | str starts-with '?')
    | length
  } else {
    0
  })

  let worktree_modified_count = (if $has_staging_or_worktree_changes {
    $staging_worktree_table
    | where worktree in ['M', 'R']
    | length
  } else {
    0
  })

  let worktree_deleted_count = (if $has_staging_or_worktree_changes {
    $staging_worktree_table
    | where worktree == 'D'
    | length
  } else {
    0
  })

  let merge_conflict_count = (if $has_unresolved_merge_conflicts {
    $status
    | where ($it | str starts-with 'u')
    | length
  } else {
    0
  })

  {
    in_git_repo: $in_git_repo,
    repo_toplevel: ($repo_toplevel | str trim -r),
    on_named_branch: $on_named_branch,
    branch_name: $branch_name,
    commit_hash: $commit_hash,
    tracking_upstream_branch: $tracking_upstream_branch,
    upstream_exists_on_remote: $upstream_exists_on_remote,
    commits_ahead: $commits_ahead,
    commits_behind: $commits_behind,
    staging_added_count: $staging_added_count,
    staging_modified_count: $staging_modified_count,
    staging_deleted_count: $staging_deleted_count,
    untracked_count: $untracked_count,
    worktree_modified_count: $worktree_modified_count,
    worktree_deleted_count: $worktree_deleted_count,
    merge_conflict_count: $merge_conflict_count
  }
}
