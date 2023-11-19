export def parse_porcelain [info_lines: list<string>] {
  if ($info_lines | is-empty) { return [] }

  let parsed_status = ($info_lines | reduce -f {
    branch: {},
    # 1 <XY> <sub> <mH> <mI> <mW> <hH> <hI> <path>
    OrdinaryChanges: []
    # 2 <XY> <sub> <mH> <mI> <mW> <hH> <hI> <X><score> <path><sep><origPath>
    RenameCopiesChanges: []
    # u <XY> <sub> <m1> <m2> <m3> <mW> <h1> <h2> <h3> <path>
    UnmergedChanges: []
    # ? <path>
    IgnoredChanges: []
    # ! <path>
    UntrackedChanges: []
  } {|line, status|
    mut status = $status
    # Parse headers
    if ($line | str starts-with '# branch.') {
      # Line                                     Notes
      # ------------------------------------------------------------
      # branch.oid <commit> | (initial)        Current commit.
      # branch.head <branch> | (detached)      Current branch.
      # branch.upstream <upstream_branch>      If upstream is set.
      # branch.ab +<ahead> -<behind>           If upstream is set and
      #		                             	      the commit is present.
      # ------------------------------------------------------------
      let header_entry = ($line | str substring 9.. | split column ' ' type value1 value2 )
      let key = $header_entry.type.0
      match $key {
        'oid' => {
          $status.branch.oid = $header_entry.value1.0
        },
        'head' => {
          $status.branch.head = $header_entry.value1.0
        },
        'upstream' => {
          $status.branch.upstream = $header_entry.value1.0
        },
        'ab' => {
          $status.branch.ab = { 
            ahead: ($header_entry.value1.0 | into int),
            behind: ($header_entry.value2.0 | into int),
          }
        }
      }
    } else if ($line | str starts-with '# stash ') {
      $status.stash = ($line | str substring 8..9 | into int)
    } else {
      let type = ($line | str substring 0..1)
      match $type {
        '1' => { 
          # 1 <XY> <sub> <mH> <mI> <mW> <hH> <hI> <path>
          let ordinaryChangeEntry = ($line | str substring 2.. | split column -c ' ' xy sub mH mI mW hH hI path)
          $status.OrdinaryChanges = ($status.OrdinaryChanges | append $ordinaryChangeEntry)
        },
        2 => {
          # 2 <XY> <sub> <mH> <mI> <mW> <hH> <hI> <X><score> <path><sep><origPath>
          let renameCopiesChangesEntry = ($line | str substring 2.. | split column -c ' ' xy sub mH mI mW hH hI Xscore pathSepOriginPath)
          $status.RenameCopiesChanges = ($status.RenameCopiesChanges | append $renameCopiesChangesEntry)
        },
        'u' => {
          # u <XY> <sub> <m1> <m2> <m3> <mW> <h1> <h2> <h3> <path>
          let unmergedChangeEntry = ($line | str substring 2.. | split column -c ' ' xy sub m1 m2 m3 mW h1 h2 h3 path)
          $status.UnmergedChanges = ($status.UnmergedChanges | append $unmergedChangeEntry)
        },
        '?' => {
          let untrackedChangeEntry = ($line | str substring 2.. | split column -c ' ' path)
          $status.UntrackedChanges = ($status.UntrackedChanges | append $untrackedChangeEntry)

        },
        '!' => {
          let ignoredChangeEntry = ($line | str substring 2.. | split column -c ' ' path)
          $status.IgnoredChanges = ($status.IgnoredChanges | append $ignoredChangeEntry)
        },
      }
    }

    $status    
  })

  return $parsed_status
}

export def git_status [] {
  let raw_status = (do -i { git --no-optional-locks status --porcelain=2 --branch --show-stash | lines -s})
  let parsed_status = parse_porcelain $raw_status

  let change_count = ($parsed_status.OrdinaryChanges | length) + ($parsed_status.RenameCopiesChanges | length) + ($parsed_status.IgnoredChanges | length) + ($parsed_status.UntrackedChanges | length)

  $parsed_status
}
