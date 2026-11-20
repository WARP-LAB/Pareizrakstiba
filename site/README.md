# Site

Bilingual (English / Latvian) GitHub Pages site. The markdown pages in
`en/` and `lv/` are rendered by Jekyll into static HTML and deployed by
`.github/workflows/pages.yml`.

## Layout

```text
site/
  _config.yml             site title, URL, per-directory page defaults
  _layouts/default.html   HTML shell: head, header, switcher, footer
  _includes/              partials (language switcher)
  assets/style.css        shared stylesheet (light and dark)
  index.html              language chooser / redirect at /
  robots.txt              crawl rules, points at sitemap.xml
  en/index.md             English home page
  lv/index.md             Latvian home page
  media/                  images and screenshots
```

The URL mirrors the directory: `en/index.md` becomes `/en/`,
`en/install.md` becomes `/en/install`.

## Adding a page

Create the same file in both language directories, e.g. `en/install.md`
and `lv/install.md`. Only `title` (and optionally `description`) goes in
the front matter - `layout` and `lang` come from the `defaults` in
`_config.yml`, based on the directory:

```markdown
---
title: Install
description: How to install Pareizrakstība.
---

# Install
```

Do not translate filenames: the language switcher and the `hreflang`
links rely on both languages having the same path.

Optional front matter, all emitted by the layout: `description` (used for
the meta description and Open Graph) and `keywords` (a list, joined with
commas). Keep keywords to the handful of phrases the page really is
about; the tag is ignored by Google and over-stuffing only looks spammy.

```markdown
---
title: Install
description: How to install Pareizrakstība on macOS.
keywords:
  - install Latvian spellcheck
  - pareizrakstības uzstādīšana
---
```

## SEO

What the layout already emits, when `url` is set in `_config.yml`:

- unique `<title>` and meta description per page, `<html lang>`
- `rel="canonical"` and paired `hreflang` links between `/en/` and `/lv/`
- Open Graph and Twitter card tags, with `og:locale` per language
- JSON-LD `SoftwareApplication` structured data
- `/sitemap.xml` (jekyll-sitemap) and `/robots.txt` pointing at it
- `noindex` plus `sitemap: false` on the redirect at `/`

Rankings still come from the page text: keep the first paragraph a plain
description of what the app does, and give every page one `<h1>`.

## How linking works

There is no `baseurl` to configure and no `relative_url` filter to
remember. The layout computes how deep the current page sits inside its
language directory and emits plain relative links (`../assets/style.css`,
`../lv/`). The same files therefore work at a custom domain and at
`<user>.github.io/<repo>/` unchanged.

`url` in `_config.yml` is only used for canonical and `hreflang` links,
which must be absolute.

Images work the same way: author them relative to the page, e.g. from
`en/index.md` use `![TextEdit](../media/screenshots/screen-01.png)`. The
same file is referenced from both languages because they sit at the same
depth. `main img` in `assets/style.css` centres them and caps them at
their intrinsic size (`max-width: 100%`, no `width: 100%`), so a small
screenshot is never stretched and a wide one never overflows the column.

`relative_links` is disabled in `_config.yml` for this reason: that
github-pages plugin rewrites `../media/x.png` to `/media/x.png`, which
only resolves when `baseurl` matches the deploy path.

## Publishing

In the repository settings, set **Pages → Build and deployment → Source**
to **GitHub Actions**. Nothing else to configure: pushing to `master`
touches `site/**` and the workflow builds and deploys the site.

Publishing from a branch is not an option here, because that mode only
serves the repository root or `/docs`, not an arbitrary `site/` folder.

## Local preview

Any Ruby 3.1+ with Jekyll works; no plugins are used.

```zsh
gem install jekyll
jekyll serve --source site --livereload
```

Or, without installing Ruby gems:

```zsh
docker run --rm -it -v "$PWD/site:/srv/jekyll" -p 4000:4000 \
  jekyll/jekyll jekyll serve --livereload
```

### Exact CI build into .tmp/site

Same image the workflow uses, same flags - no Ruby install needed.
`.tmp/` is gitignored, so the output never shows up in `git status`.

```zsh
rm -rf .tmp/site && mkdir -p .tmp
docker run --rm \
  -e GITHUB_WORKSPACE=/github/workspace \
  -e INPUT_SOURCE=./site \
  -e INPUT_DESTINATION=./.tmp/site \
  -v "$PWD:/github/workspace" \
  ghcr.io/actions/jekyll-build-pages:v1.0.13

python3 -m http.server 8765 --directory .tmp/site
# http://127.0.0.1:8765/
```

Serve over HTTP rather than opening the files directly: the chooser at `/`
redirects to `en/` or `lv/`, and a `file://` URL has no directory index
resolution, so that redirect would land on a file listing.

## Adding a third language

Add a directory and a `defaults` entry in `_config.yml`, then extend the
`other` logic in `_layouts/default.html` and the label map in
`_includes/lang-switcher.html`. Two languages keep that logic trivial;
beyond two it is worth replacing the switcher with a loop over a list
from `_config.yml`.
