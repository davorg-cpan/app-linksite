# Developing App::LinkSite

App::LinkSite is a CPAN distribution and a static-site generator. Start with
[README.md](README.md) for the input format and user workflow. This guide
describes the implementation and how to verify changes locally.

## Repository map

| Path | Responsibility |
| --- | --- |
| `bin/linksite` | CLI option parsing and entry point. |
| `lib/App/LinkSite.pm` | Reads JSON, builds model objects, configures Template Toolkit, and writes the site. |
| `lib/App/LinkSite/Site.pm` | Site fields, section detection, aggregation of links, and JSON-LD. |
| `lib/App/LinkSite/Link.pm` | Link fields and rendering a Bootstrap list item. |
| `lib/App/LinkSite/Section.pm` | Section title, link objects, and `has_links`. |
| `lib/App/LinkSite/Social.pm` | Supported services, profile URL construction, and Font Awesome anchor rendering. |
| `src/index.html.tt` | Page structure, metadata, analytics, section layout, and CDN dependencies. |
| `src/css/style.css` | Local styles, body color defaults, and the “New!” marker. |
| `t/` | Tests using Test::More and a JSON fixture. |
| `example/` | Flat and sectioned configurations, plus a consumer's Pages workflow. |
| `docker/` | Image definition and a build-and-push helper for published CPAN versions. |
| `Makefile.PL`, `cpanfile`, `MANIFEST` | Distribution metadata, dependencies, and packaged files. |
| `.github/workflows/perltest.yml` | Reusable CI jobs for tests, coverage, Perl::Critic, and complexity. |
| `.github/workflows/static.yml` | Publishes this project's README as its documentation website. |
| `docs/` | Tracked documentation-site files from the Jekyll setup; also the default output path when generating a link site. |

There is no application server, database, frontend build pipeline, or Node
dependency tree. Runtime HTML uses Bootstrap and Font Awesome from CDNs.

## Local setup

Use Perl 5.26 or later and a CPAN client. From the repository root:

```sh
cpanm --installdeps .
perl Makefile.PL
make
make test
```

For a quick run against source modules without rebuilding:

```sh
prove -Ilib -v t
```

`cpanfile` lists prerequisites; `Makefile.PL` supplies MakeMaker/CPAN metadata
and uses File::ShareDir::Install to install `src/` as distribution share files.
Keep both dependency declarations consistent when changing requirements.
`Makefile`, `MYMETA.*`, `blib/`, `pm_to_blib`, and release tarballs are generated
and ignored by Git. They may already exist and may be stale.

The classes use Feature::Compat::Class and `field`, `:param`, `:reader`,
`ADJUST`, and `method` syntax. Object::Pad supplies compatibility on older
Perls. Follow the existing class style rather than introducing a second
object system. CI currently declares Perl 5.26 through 5.40 in two-version
steps; check the workflow when changing language features or dependencies.

## Build lifecycle

1. `bin/linksite` parses options and normally calls
   `App::LinkSite->new(...)->run`.
2. Construction immediately reads and decodes the input in `ADJUST`. It
   takes `ga4` from JSON, creates Template Toolkit with `src` as `INCLUDE_PATH`
   and `out` as `OUTPUT_PATH`, and exposes `ga4` and `version` to templates.
3. Missing social handles inherit the top-level `handle` using `//=`. Social,
   link, and section data become `Social`, `Link`, and `Section` objects.
   A `Site` object collects these and the profile fields.
4. `run` creates `out` and traverses `src` with File::Find and `no_chdir`.
   Each `.tt` file is processed with the additional template variable `site`.
   Output template names use `basename($path, '.tt')`, so nested templates
   currently render at the output root. Other files and directories preserve
   their relative paths.
5. The two configured images are copied from the working directory's `img/`
   into `out/img/`. A working-directory `CNAME`, if present, is copied next.
   Finally the original input file is copied into `out` under its basename.

Construction can fail before `run` because JSON loading and object creation
happen in `ADJUST`. A failure during rendering or copying can leave partial
output. Builds overwrite matching files but do not clean obsolete files.
There is no schema validator or general HTML-escaping layer.

### Constructor and path behavior

| Parameter | Default / behavior |
| --- | --- |
| `file` | `links.json`, relative to the working directory unless absolute. |
| `src` | Installed `File::ShareDir::dist_dir('App-LinkSite')`, if found; otherwise `$FindBin::Bin/../src`. |
| `out` | `docs`, relative to the working directory unless absolute. |
| `ga4` | Accepted as a parameter but overwritten by the input's `ga4` or `''`. |
| `site` | Accepted as a parameter but replaced by the site constructed from JSON. |

The installed share directory takes precedence even when loading modules
with `-Ilib`. The fallback is relative to the running script, not this module
or necessarily the current directory. Use an explicit absolute `src` for
reliable source-tree template testing. A custom `file` does not relocate
image or `CNAME` lookups to that file's directory.

### Model and rendering details

`Site::has_sections` is true only if at least one section has links. The
template then renders non-empty sections followed by any top-level links
under “Other links”. Otherwise it renders the top-level list without
section headings.

`Site::all_links` returns a Perl list, starting with top-level links and then
each section's links. `json_ld` uses this order for `relatedLink`, even though
the sectioned HTML displays top-level links last. It also emits a WebPage
with a Person `mainEntity` and social URLs in `sameAs`.

`Link::mk_link` returns the entire `<li>` containing the anchor and optional
subtitle. The constructor parameter `new` is stored in `$new_link` and read
through `is_new`; CSS renders the visible label for the `new-link` class.

`Social::mk_social_link` returns an explicit `url` first. Otherwise it finds
the service pattern, substitutes `XXXX` for subdomain-based profiles, or
appends the handle. An unknown service warns and returns no generated URL.
`mk_social_icon` uses the service's display name and Font Awesome brand key,
so a custom URL alone does not make a new service fully supported.

## Safely preview source changes

Do not run a default build in the repository root: it writes into the tracked
`docs/` directory. This recipe uses a temporary content directory, explicitly
selects the checkout's templates, and needs no image files:

```sh
repo_dir="$PWD"
preview_dir=$(mktemp -d)
cp t/links.json "$preview_dir/links.json"
cd "$preview_dir"
perl -MJSON -e 'local $/; my $d = decode_json(<>); $d->{image} = ""; $d->{og_image} = ""; delete $d->{ga4}; print encode_json($d)' links.json > preview.json
perl -I"$repo_dir/lib" -MApp::LinkSite -e 'App::LinkSite->new(file => "preview.json", src => $ARGV[0], out => "public")->run' "$repo_dir/src"
python3 -m http.server 8000 --directory public
```

Visit `http://localhost:8000/`. Stop the server with Ctrl-C and return to
`repo_dir` before further repository commands. `LINKSITE_DEBUG=1` enables
the builder's path/copy diagnostics on stderr. Output includes a build
timestamp, so byte-for-byte HTML comparisons need to account for that.

## Verification and test gaps

The current suite contains six files and 38 assertions. It covers model
construction/readers, colors, sections, link aggregation, default paths,
and the driver's custom input parameter. `t/basic.t` marks its source-path
expectation as TODO because an installed share directory can take precedence.
That TODO failure is not a suite failure.

`t/file-parameter.t` copies a fixture to root-level `links.json` and unlinks
it afterwards. Do not keep personal content at that path when running the
suite. The suite currently does not exercise CLI generation, a full `run`,
rendered HTML, or most social URL patterns. A passing suite alone will not
catch a template or command-line regression.

For rendering or asset changes, also build into a temporary directory and
check `index.html`, `css/style.css`, configured images, copied input, and
`CNAME` where applicable. Exercise both a flat list and sections with an
empty section and top-level links. For social-service changes, check the URL,
display name, icon key, inherited handle, and explicit URL override. Add
focused regression tests when changing behavior that is not covered.

Before finishing a change, run:

```sh
prove -Ilib -v t
git diff --check
git status --short
```

## Known issues to account for

These describe the checked-in implementation, rather than intended behavior:

- `bin/linksite` exits whenever any recognized option is set. This makes
  `--help` and `--version` work but prevents `--file` from reaching the build.
  The existing custom-file test exercises the constructor only.
- Local CSS and profile images use domain-root paths, so subpath hosting
  needs template changes. `site_url` is only used for Open Graph metadata;
  it is not inferred or normalized, and its image URL concatenation needs
  a trailing `/`.
- The GA4 loader URL has a hard-coded measurement ID while its configuration
  uses the input's `ga4` value.
- The consumer workflow spells `branches` as `branchs`, and its path filter
  omits images and `CNAME`.
- The social fixture uses `service => 'twitter'` with an explicit URL and
  only tests readers. The supported service key for generated icons/URLs is
  `x-twitter`.
- `MANIFEST` does not currently include `t/section.t`, `t/file-parameter.t`,
  or `example/links-with-sections.json`. Audit packaged tests and examples
  before a release; a source-checkout test run covers more than the tarball.
- Some configure-prerequisite entries in `Makefile.PL` use `>=` where the
  hash needs `=>`. `perl Makefile.PL` can therefore warn about an undefined
  requirement and a prerequisite with an empty name. In the inspected
  environment it still generated the Makefile and `make test` passed.
  Recheck generated metadata when maintaining dependencies.

Keep documentation accurate if these issues are fixed; do not preserve a
bug merely because it is documented.

## Documentation, CI, and releases

`README.md` is the canonical user guide. The active documentation workflow
converts it to `_site/index.html` using `davorg/readme-to-index`, then deploys
that artifact. It watches README changes. `docs/index.md`, `_config.yml`,
and `CNAME` belong to the older Jekyll arrangement; `docs/README.md` points
readers to the canonical guide instead of maintaining a second copy.
The consumer workflow in `example/build.yml` deploys generated link pages
and is separate from this repository's documentation workflow.

Keep `MANIFEST` current for files that must ship. Use `make distcheck` to
review its warnings and inspect
the archive if preparing a release; repository-only CI and docs files may
intentionally be excluded.

See [docker/README.md](docker/README.md) for the container workflow. The
Dockerfile installs a version from CPAN, not the checkout. `docker/build`
publishes images to Docker Hub, so it is a release operation rather than a
local verification command.

### Versioning

App::LinkSite follows Semantic Versioning (SemVer): `MAJOR.MINOR.PATCH`.
Assess compatibility across the documented JSON configuration format, CLI,
and public Perl API when choosing a release version.

For stable releases (`1.0.0` and later):

- Increment `MAJOR` for incompatible public interface changes, resetting
  `MINOR` and `PATCH` to zero.
- Increment `MINOR` for backward-compatible functionality or deprecation of
  public functionality, resetting `PATCH` to zero.
- Increment `PATCH` for backward-compatible bug fixes.

The current `0.x.y` series is initial development under SemVer: the public
API is not yet considered stable and compatibility is not guaranteed.
Describe breaking changes and any migration steps explicitly in `Changes.md`.

Record release changes in `Changes.md`. `VERSION_FROM` in `Makefile.PL`
points at `lib/App/LinkSite.pm`; all four model modules also declare versions.
Keep all five declarations aligned when preparing a release. Do not change
an already published version's contents; publish a new version instead.
Routine documentation edits do not require a version bump on their own.
