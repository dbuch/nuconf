# source init.nu

use prompt.nu pre_prompt_hook
use prompt.nu create_left_prompt
use prompt.nu create_right_prompt

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
    file_format: "sqlite"
  }

  completions: {
    case_sensitive: true,
  }
  filesize: {
    metric: true
    format: "auto"
  }
  bracketed_paste: true
  cursor_shape: {
    vi_insert: line 
    vi_normal: block
  }
  color_config: (source theme.nu)
  footer_mode: "25"
  edit_mode: vi
  menus: [
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
  ]
})

$env.config.keybindings = [
    {
      name: completion_menu
      modifier: Alt
      keycode: char_l
      mode: [vi_normal, vi_insert]
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
      mode: [vi_normal, vi_insert]
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
      mode: [vi_normal, vi_insert]
      event: {
        until: [
          {edit: cuttolineend}
        ]
      }
    }
    {
      name: commands_menu
      modifier: control
      keycode: char_t
      mode: [vi_normal, vi_insert]
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
      mode: [vi_normal, vi_insert]
      event: { send: menu name: vars_menu }
    }
    {
      name: commands_with_description
      modifier: control
      keycode: char_s
      mode: [vi_normal, vi_insert]
      event: { send: menu name: commands_with_description }
    }
    {
        name: exit
        modifier: none
        keycode: char_q
        mode: [vi_normal]
        event: {
            send: executehostcommand
            cmd: "exit"
        }
    }
    {
        name: insert_newline
        modifier: alt
        keycode: enter
        mode: [emacs vi_normal vi_insert]
        event: { edit: insertnewline }
    }
  ]

$env.PROMPT_COMMAND = {|| create_left_prompt }
$env.PROMPT_COMMAND_RIGHT = {|| create_right_prompt }

$env.PROMPT_INDICATOR = {|| " ❯ " }
$env.PROMPT_INDICATOR_VI_INSERT = {|| " ❯ " }
$env.PROMPT_INDICATOR_VI_NORMAL = {|| " ❮ " }
$env.PROMPT_MULTILINE_INDICATOR = {|| "::: " }

source ($nu.default-config-dir | path join "aliases.nu")
source ($nu.default-config-dir | path join "completion.nu")
source ($nu.default-config-dir | path join "hooks.nu")
source ($nu.default-config-dir | path join "keybindings.nu")
source ($nu.default-config-dir | path join "menus.nu")

export def la [path?: string = ""] {
  ls -l $path | sort-by type | select mode name size modified
}
