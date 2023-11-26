source init.nu

use prompt.nu pre_prompt_hook

$env.config = ($env.config? | default {} | merge {
  show_banner: false
  ls: {
    use_ls_colors: true
    clickable_links: true
  }
  rm: {
    always_trash: false
  }
  table: {
    mode: compact
    index_mode: auto
    show_empty: true,
    padding: { left: 0, right: 0 }
    header_on_separator: true,
  }

  history: {
    file_format: "sqlite" # "sqlite" or "plaintext"
  }

  completions: {
    case_sensitive: true,
  }
  filesize: {
    metric: true
    format: "auto"
  }
  cursor_shape: {
    vi_insert: line # block, underscore, line (block is the default)
    vi_normal: block # block, underscore, line  (underscore is the default)
  }
  color_config: (source theme.nu) # if you want a light theme, replace `$dark_theme` to `$light_theme`
  footer_mode: "25"
  edit_mode: vi
  menus: [
      # Configuration for default nushell menus
      # Note the lack of souce parameter
      {
        name: completion_menu
        only_buffer_difference: false
        marker: " | "
        type: {
            layout: columnar
            columns: 4
            col_width: 20   # Optional value. If missing all the screen width is used to calculate column width
            col_padding: 2
        }
        style: {
            text: green
            selected_text: green_reverse
            description_text: yellow
        }
      }
      {
        name: history_menu
        only_buffer_difference: true
        marker: " ? "
        type: {
            layout: list
            page_size: 10
        }
        style: {
            text: green
            selected_text: green_reverse
            description_text: yellow
        }
      }
      {
        name: bookmarks_menu
        only_buffer_difference: true
        marker: " ? "
        type: {
            layout: list
            page_size: 10
        }
        style: {
            text: green
            selected_text: green_reverse
            description_text: yellow
        }
        source: { |buffer, position|
            open "/home/dbuch/.bookmarks"
            | lines |
            each { |bm| { value: ($bm | str trim)}}

        }
      }
      {
        name: help_menu
        only_buffer_difference: true
        marker: " ? "
        type: {
            layout: description
            columns: 4
            col_width: 20   # Optional value. If missing all the screen width is used to calculate column width
            col_padding: 2
            selection_rows: 4
            description_rows: 10
        }
        style: {
            text: green
            selected_text: green_reverse
            description_text: yellow
        }
      }
      {
        name: commands_menu
        only_buffer_difference: false
        marker: " # "
        type: {
            layout: columnar
            columns: 4
            col_width: 20
            col_padding: 2
        }
        style: {
            text: green
            selected_text: green_reverse
            description_text: yellow
        }
        source: { |buffer, position|
            $nu.scope.commands
            | where name =~ $buffer
            | each { |it| {value: $it.name description: $it.usage} }
        }
      }
      {
        name: vars_menu
        only_buffer_difference: true
        marker: " # "
        type: {
            layout: list
            page_size: 10
        }
        style: {
            text: green
            selected_text: green_reverse
            description_text: yellow
        }
        source: { |buffer, position|
            $nu.scope.vars
            | where name =~ $buffer
            | sort-by name
            | each { |it| {value: $it.name description: $it.type} }
        }
      }
      {
        name: commands_with_description
        only_buffer_difference: true
        marker: " # "
        type: {
            layout: description
            columns: 4
            col_width: 20
            col_padding: 2
            selection_rows: 4
            description_rows: 10
        }
        style: {
            text: green
            selected_text: green_reverse
            description_text: yellow
        }
        source: { |buffer, position|
            $nu.scope.commands
            | where name =~ $buffer
            | each { |it| {value: $it.name description: $it.usage} }
        }
      }
  ]
  keybindings: [
    {
      name: completion_menu
      modifier: Alt
      keycode: char_l
      mode: [vi_normal, vi_insert] # Options: emacs vi_normal vi_insert
      event: {
        until: [
          { send: menu name: completion_menu }
          { send: menunext }
        ]
      }
    }
    {
      name: completion_previous
      modifier: Alt
      keycode: char_h
      mode: [vi_normal, vi_insert]
      event: { send: menuprevious }
    }
    {
      name: completion_up
      modifier: Alt
      keycode: char_k
      mode: [vi_normal, vi_insert]
      event: { send: menuup }
    }
    {
      name: completion_down
      modifier: Alt
      keycode: char_j
      mode: [vi_normal, vi_insert]
      event: { send: menudown }
    }
    {
      name: history_menu
      modifier: Alt
      keycode: char_r
      mode: [vi_normal, vi_insert]
      event: { send: menu name: history_menu }
    }
    {
      name: next_page
      modifier: control
      keycode: char_x
      mode: vi_normal
      event: { send: menupagenext }
    }
    {
      name: undo_or_previous_page
      modifier: control
      keycode: char_z
      mode: vi_normal
      event: {
        until: [
          { send: menupageprevious }
          { edit: undo }
        ]
       }
    }
    {
      name: unix-line-discard
      modifier: control
      keycode: char_u
      mode: [emacs, vi_normal, vi_insert]
      event: {
        until: [
          {edit: cutfromlinestart}
        ]
      }
    }
    {
      name: kill-line
      modifier: control
      keycode: char_k
      mode: [emacs, vi_normal, vi_insert]
      event: {
        until: [
          {edit: cuttolineend}
        ]
      }
    }
    # Keybindings used to trigger the user defined menus
    {
      name: commands_menu
      modifier: control
      keycode: char_t
      mode: [emacs, vi_normal, vi_insert]
      event: { send: menu name: commands_menu }
    }
    {
      name: bookmarks
      modifier: Alt
      keycode: char_b
      mode: [vi_normal, vi_insert]
      event: { send: menu name: bookmarks_menu }
    }
    {
      name: vars_menu
      modifier: alt
      keycode: char_o
      mode: [emacs, vi_normal, vi_insert]
      event: { send: menu name: vars_menu }
    }
    {
      name: commands_with_description
      modifier: control
      keycode: char_s
      mode: [emacs, vi_normal, vi_insert]
      event: { send: menu name: commands_with_description }
    }
  ]
})

source ($nu.default-config-dir | path join "aliases.nu")
source ($nu.default-config-dir | path join "completion.nu")
source ($nu.default-config-dir | path join "hooks.nu")
source ($nu.default-config-dir | path join "keybindings.nu")
source ($nu.default-config-dir | path join "menus.nu")
