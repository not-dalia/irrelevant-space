# Obsidian Meadow

Obsidian Meadow is a collection of Jekyll plugins for building Jekyll Digital Gardens using Obsidian files. 

**Important Note:** Obsidian Meadow flattens URLs/permalinks to follow a structure similar to Obsidian allowing linking to files using filenames only. Any existing permalink rules might be ignored.


## Features

Obsidian Meadow adds support for:

1. **Callouts**
2. **Document/Internal Link Embeds**
3. **Internal Link Preview on Hover**
4. **Page Mentions and Internal Backlinks**
5. **External Link Detection**
6. **Dead Internal Link Detection**

## Installation

1. Place the plugin files into your Jekyll site's `_plugins` directory.
2. Update your `_config.yml` file with the following settings:

```yaml
markdown: ObsidianKramdown
kramdown:
  input: Obsidian

collections:
  notes:
    output: true
    permalink: :slugified_path/
    images_dir: assets
    destination: assets

exclude:
  - scripts/backlinks.json
  - scripts/broken_links.json
  - _notes/.obsidian
  - _notes/_private
  - _notes/.obsidian

keep_files:
  - scripts/backlinks.json
  - scripts/broken_links.json

obsidian_meadow:
  enabled: true
  excluded_collections:
    - posts
  excluded_pages:
    - about
  assets_folder:
    - assets
  prepend_frontmatter:
    enabled: true
```

## Configuration

The `obsidian_meadow` section in your `_config.yml` allows you to customize the plugin's behavior:

- `enabled`: Set to `true` to activate the plugin.
- `excluded_collections`: List collections you want to exclude from processing.
- `excluded_pages`: Specify individual pages to exclude.
- `assets_folder`: Specify the path to the assets folder.
- `prepend_frontmatter`: Enable automatic frontmatter including title and created/updated dates.
