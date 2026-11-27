# App::LinkSite

Generate a small, self-hosted links page from a JSON file. App::LinkSite is a
Perl command-line application: it builds static HTML and CSS that you can serve
from any static web host. No Perl installation is needed on the web server.

The page includes a profile, social icons, links, optional section headings,
Open Graph metadata, and JSON-LD structured data. See the
[live example](https://links.davecross.co.uk/).

For development and architecture, see
[CONTRIBUTING.md](https://github.com/davorg-cpan/app-linksite/blob/main/CONTRIBUTING.md).
Coding agents should start with
[AGENTS.md](https://github.com/davorg-cpan/app-linksite/blob/main/AGENTS.md).

## Build your first page

Install Perl 5.26 or later and App::LinkSite using your usual CPAN client:

```sh
cpanm App::LinkSite
mkdir my-links
cd my-links
```

Save this as `links.json` in that directory:

```json
{
  "name": "Example Person",
  "handle": "example",
  "desc": "Things I make and places to find me.",
  "site_url": "https://links.example.com/",
  "image": "",
  "og_image": "",
  "social": [
    { "service": "github" },
    { "service": "mastodon", "url": "https://social.example/@example" }
  ],
  "links": [
    {
      "title": "My website",
      "subtitle": "Projects and writing",
      "link": "https://example.com/",
      "new": 1
    },
    { "title": "Email", "link": "mailto:me@example.com" }
  ]
}
```

Replace the example names and URLs, then build:

```sh
linksite
```

The generated site is in `docs/`. To preview it locally with Python installed:

```sh
python3 -m http.server 8000 --directory docs
```

Open `http://localhost:8000/`. Upload the **contents** of `docs/` to your web
host's document root when ready. The page loads Bootstrap and Font Awesome
from public CDNs, so full styling and icons require network access.

Run builds in your content directory. The default output directory is relative
to your current working directory, as are image and `CNAME` lookups. Rebuilding
overwrites matching output files but does not remove old files.

## Configuration reference

The input is one JSON object. The site-wide fields below are top-level keys;
there is no separate `frontmatter` object. Use arrays of objects for `social`,
`links`, and `sections`. Include `social: []` or `links: []` when you have no
entries; for a site containing only sections, use `links: []`.

### Site settings

| Key | Meaning |
| --- | --- |
| `name` | Display name, used in the heading, page title, and metadata. |
| `handle` | Default social handle; also shown with `@` in the page heading. Supply it without a leading `@`. |
| `desc` | Profile description. Newlines become line breaks in the page; simple HTML is also accepted. |
| `site_url` | Public URL of the page, including a trailing `/`, for Open Graph metadata. No URL is inferred when it is omitted. |
| `image` | Profile image filename inside your local `img/` directory. Use `""` or omit it for no image. |
| `og_image` | Social sharing image filename inside `img/`. Use `""` or omit it for no image. |
| `text_color` | Optional CSS color, for example `"#222222"`. Default body text is black. |
| `background_color` | Optional CSS color, for example `"#fafafa"`. Default body background is white. |
| `ga4` | Optional Google Analytics measurement ID. Omit it to leave out analytics. See the limitation below. |

Color settings apply to the body; Bootstrap components and social icons have
their own styles.

### Images and custom domains

For `"image": "avatar.jpg"` and `"og_image": "preview.png"`, prepare:

```text
my-links/
  links.json
  img/
    avatar.jpg
    preview.png
  CNAME             # optional: hostname for GitHub Pages
```

Use filenames directly inside `img/`, without the `img/` prefix or a full URL.
Only the two named images are copied to `docs/img/`; the whole directory is not
copied. A `CNAME` file in the working directory is copied to `docs/CNAME`.
Configure your host and DNS separately for a custom domain.

### Social accounts

Each object in `social` accepts:

| Key | Meaning |
| --- | --- |
| `service` | One of the identifiers below; determines the URL pattern and Font Awesome icon. |
| `handle` | Optional override of the top-level handle. Handles are inserted as supplied, without URL encoding. |
| `url` | Optional complete profile URL; overrides the generated URL. Use this for other Mastodon instances or unusual profiles. |

These are the URL patterns implemented by this version; `{handle}` is replaced
by the account's handle:

| Service | Generated URL |
| --- | --- |
| `facebook` | `https://facebook.com/{handle}` |
| `x-twitter` | `https://twitter.com/{handle}` |
| `instagram` | `https://instagram.com/{handle}` |
| `tiktok` | `https://tiktok.com/@{handle}` |
| `linkedin` | `https://linkedin.com/in/{handle}` |
| `substack` | `https://{handle}.substack.com/` |
| `github` | `https://github.com/{handle}` |
| `medium` | `https://{handle}.medium.com/` |
| `reddit` | `https://reddit.com/user/{handle}` |
| `quora` | `https://quora.com/profile/{handle}` |
| `mastodon` | `https://fosstodon.org/@{handle}` |
| `threads` | `https://www.threads.net/@{handle}` |
| `bluesky` | `https://bsky.app/profile/{handle}` |
| `letterboxd` | `https://letterboxd.com/{handle}` |
| `lastfm` | `https://last.fm/user/{handle}` |
| `ko-fi` | `https://ko-fi.com/{handle}` |

Use `x-twitter` rather than `twitter`. A custom `url` changes the destination
but does not add an icon for an unsupported service. Social anchors include
`rel="me"`.

### Links

Each object in `links`, including links inside a section, accepts:

| Key | Meaning |
| --- | --- |
| `title` | Required link text. |
| `link` | Required destination URL; `mailto:` links work too. |
| `subtitle` | Optional smaller text beneath the title. |
| `new` | Optional truthy flag (`1` or `true`) that adds a red “New!” label. Defaults to false. |

### Sections

Add a top-level `sections` array to group links:

```json
"sections": [
  {
    "title": "Projects",
    "links": [
      { "title": "My project", "link": "https://example.com/project" }
    ]
  },
  { "title": "Coming soon", "links": [] }
],
"links": [
  { "title": "Contact", "link": "mailto:me@example.com" }
]
```

This is a fragment to insert into the main JSON object. Non-empty sections
appear in their input order. Empty sections are hidden. When at least one
section has links, top-level links appear afterwards under “Other links”.
When all sections are empty or `sections` is omitted, top-level links appear
as a flat list. With no top-level links, “Other links” is omitted.

Full examples are in
[example/links.json](https://github.com/davorg-cpan/app-linksite/blob/main/example/links.json)
and
[example/links-with-sections.json](https://github.com/davorg-cpan/app-linksite/blob/main/example/links-with-sections.json).
Their image filenames and analytics values are placeholders; supply your own
images or clear those fields before building.

## Commands and alternate input files

```sh
linksite            # build links.json into docs/
linksite --help     # display usage
linksite --version  # display installed version
LINKSITE_DEBUG=1 linksite
```

**Current CLI limitation:** `--file` is advertised by the command's help but
exits without generating a site. Positional filenames are not supported.
For a different input filename, use the working Perl API:

```sh
perl -MApp::LinkSite -e 'App::LinkSite->new(file => "profile.json")->run'
```

You can also select a different output directory through the API:

```sh
perl -MApp::LinkSite -e 'App::LinkSite->new(file => "profile.json", out => "public")->run'
```

Even with a different input path, images and `CNAME` are still read from the
current working directory. There are no CLI options for output directories
or template directories.

## Build with Docker or GitHub Actions

To build with the image used by the sample workflow, run this from your
content directory with Docker installed:

```sh
docker run --rm -v "$PWD:/links" davorg/links:latest linksite
```

The bind mount receives the generated `docs/`. The image's default command
prints the installed module version; specify `linksite` to build. Files may be
owned by the container user. See
[docker/README.md](https://github.com/davorg-cpan/app-linksite/blob/main/docker/README.md)
for image-building details.

For GitHub Pages automation:

1. Create a content repository with `links.json`, any images under `img/`,
   and an optional `CNAME` file.
2. Copy
   [example/build.yml](https://github.com/davorg-cpan/app-linksite/blob/main/example/build.yml)
   to `.github/workflows/build.yml` in that repository.
3. Correct the sample's `push.branchs` spelling to `push.branches`. Add
   `img/**` and `CNAME` to its `push.paths` if changes to those files should
   also trigger a build. The sample currently watches only `links.json` and
   the workflow itself.
4. In the repository's Pages settings, select **GitHub Actions** as the source.
5. Run the workflow manually from the Actions tab, or push a watched change.

The sample runs `linksite` inside `davorg/links:latest`, uploads `docs/` as a
Pages artifact, and deploys it in a separate job. It uses the released module
in that image, not code from this source repository.

**Hosting limitation:** the default template uses `/css/style.css` and
`/img/...`, which are relative to the domain root. A project URL such as
`https://username.github.io/my-links/` needs template changes for those assets
to load. Prefer a custom domain or a root site at `https://username.github.io/`.
Setting `site_url` alone does not change asset paths.

## Troubleshooting and current limits

| Symptom | What to check |
| --- | --- |
| Cannot read or decode the input | Run from the directory containing `links.json`; ensure it is valid JSON with the expected object and array shapes. There is no separate schema-validation command. |
| Missing image / copy failure | The filename must exist under `img/` in the working directory. The examples do not ship image files. |
| No output after using `--file` | Use the API command above or rename the input to `links.json`. |
| Page has no local CSS or profile image | Preview through a web server at its root; check the hosting-path limitation above. |
| Social icon or link is missing | Check the service identifier, profile handle, and whether the CDN stylesheet loads. |
| Old files remain after a rebuild | The builder does not clean the output directory. Use a new output directory or remove obsolete generated files yourself. |

The input JSON is copied into the published directory under its original
basename. Keep credentials and other private data out of it. Input values
are inserted into HTML without general escaping or sanitization, so use
content you trust and review the generated page when including HTML or quotes.

When `ga4` is set, the template uses that value in `gtag('config', ...)` but
the script URL still contains the author's hard-coded measurement ID. Check
or customize the template before relying on analytics.

App::LinkSite is free software under the same terms as Perl itself. Changes
are listed in
[Changes.md](https://github.com/davorg-cpan/app-linksite/blob/main/Changes.md).
