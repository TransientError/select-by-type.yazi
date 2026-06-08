# select-by-type.yazi

A [Yazi](https://github.com/sxyazi/yazi) plugin that selects files by MIME type category using an interactive picker (like the sort menu).

## Features

- Interactive picker with `ya.which` — press one key to select a type
- MIME-based detection — no extension lists to maintain
- Toggle behavior — press again to deselect
- Direct invocation with arguments for keybinding sequences

## Categories

| Key | Category | MIME prefix |
|-----|----------|-------------|
| `i` | Images | `image/*` |
| `v` | Video | `video/*` |
| `a` | Audio | `audio/*` |
| `t` | Text | `text/*` |
| `p` | PDF | `application/pdf` |

## Installation

```sh
ya pack -a TransientError/select-by-type
```

## Configuration

Add to your `keymap.toml`:

```toml
[[mgr.prepend_keymap]]
on = "S"
run = "plugin select-by-type"
desc = "Select files by type"
```

Or use direct keybinding sequences (skipping the picker):

```toml
[[mgr.prepend_keymap]]
on = ["S", "i"]
run = "plugin select-by-type -- image"
desc = "Select images"

[[mgr.prepend_keymap]]
on = ["S", "v"]
run = "plugin select-by-type -- video"
desc = "Select videos"

[[mgr.prepend_keymap]]
on = ["S", "a"]
run = "plugin select-by-type -- audio"
desc = "Select audio"
```

## How it works

The plugin iterates over files in the current directory and checks their MIME type (detected by Yazi). If all matching files are already selected, it deselects them (toggle). Otherwise, it selects all matching files.

## Requirements

- Yazi with MIME detection enabled (default). For best results, ensure MIME types are fetched (either via the `file` command or `mime-ext.yazi`).

## License

MIT
