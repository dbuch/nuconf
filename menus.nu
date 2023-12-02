[
  {
    name: completion_menu
    only_buffer_difference: false
    marker: " | "
    type: {
        layout: columnar
        columns: 4
        col_width: 20
        col_padding: 2
    }
    style: {
        text: green,
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
]
