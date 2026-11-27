# App::LinkSite and Linktree

Last checked: **2026-11-27**. This compares **App::LinkSite 0.2.0** with
Linktree's current public feature and help documentation. Linktree features
vary by plan; check the linked sources before relying on their availability.

App::LinkSite generates a static page from JSON, with a CLI and Perl API.
Linktree provides a managed publishing, audience, and commerce service.
Their different operating models account for many of the differences below.

## What we already cover

App::LinkSite already provides links with subtitles, grouped sections,
profile details, social icons, configurable body colours, Open Graph
metadata, JSON-LD, optional GA4 integration, and opt-in UTM tagging for
content links. Custom templates can change the generated page further.
See the [user guide](README.md) for supported configuration.

Social profile anchors do not yet inherit UTM settings; that follow-up is
tracked in [issue #48](https://github.com/davorg-cpan/app-linksite/issues/48).

## Linktree features we do not provide as built-in options

Some of these can be implemented today with custom templates or external
services. The gap is a supported configuration option or integrated workflow.

| Linktree feature | App::LinkSite 0.2.0 | Potential fit |
| --- | --- | --- |
| [Link thumbnails and featured cards](https://linktr.ee/help/articles/8580581-use-featured-layouts-links) | Links have text, subtitles, and an optional “New!” badge; no thumbnail or featured-card layout. | A strong fit, particularly for book covers and project artwork. |
| [Themes, fonts, backgrounds, and profile styles](https://linktr.ee/help/articles/5434140-an-overview-of-paid-features-available-on-linktree) | Body colours are configurable. Fonts, button styles, and backgrounds require template/CSS changes. | More design options fit the generator; header images are already [issue #8](https://github.com/davorg-cpan/app-linksite/issues/8). |
| [Scheduled and expiring links](https://linktr.ee/help/articles/5434174-schedule-links-on-your-linktree) | No start/end dates or automatic publication schedule. | Build-time date filtering could work with scheduled rebuilds. A generated page would only change when rebuilt and deployed. |
| [Embedded content](https://linktr.ee/features) and [image galleries](https://linktr.ee/help/articles/5434140-an-overview-of-paid-features-available-on-linktree) | No configured video/music players, galleries, maps, or FAQ blocks. | Selected content blocks could be rendered through templates; external embeds retain their providers' dependencies. |
| [Contact forms and email signups](https://linktr.ee/help/articles/5651972-add-contact-form) | Links can lead to a form or newsletter, but there are no form blocks or submission handling. | Integrations with external form/newsletter services could preserve static hosting. |
| [Downloadable QR codes](https://linktr.ee/help/articles/5434152-create-qr-code) | No QR generation or sharing controls. | Generating SVG/PNG assets would fit the build process. |
| [Integrated analytics reports](https://linktr.ee/help/articles/5434178-understanding-your-analytics) | GA4 integration and UTM tags are available, but there is no built-in dashboard for views, clicks, or click-through rates. | Improve integration with existing analytics tools before considering a reporting service. UTMs describe traffic at the destination; they are not a reporting dashboard. |
| [Visual editing and live preview](https://linktr.ee/features) | Users edit JSON, build, and deploy. There is no graphical editor. | A local editor or preview tool is possible, but substantially more work than adding page options. |

Linktree also documents commerce, digital downloads, bookings, access
controls, smart routing, and social posting/automation. These would be
substantial additions to App::LinkSite's scope rather than small rendering
features. See [Linktree's feature overview](https://linktr.ee/features).

## Capabilities and advantages App::LinkSite offers

Our clearest advantages concern ownership, deployment, and automation.
The Linktree documentation reviewed here describes hosted editing and
publishing, plus analytics/contact exports. It does not document a comparable
self-hosted static generator, complete template-source workflow, or local
JSON-to-site build. The comparisons below use that documented product scope;
they do not establish that Linktree has no APIs or open-source projects.

| App::LinkSite capability | Practical difference from the documented Linktree offering |
| --- | --- |
| **Self-host the actual generated page.** Deploy HTML, CSS, and assets to a static host and serve them on your own hostname. | The page's hosting and availability can be independent of Linktree's service. No Perl installation or application server is required on the web host. See [hosting](README.md#images-and-custom-domains). |
| **Keep portable input and output files.** JSON, templates, assets, and generated pages are ordinary files that can be backed up or moved. | Linktree documents exports of analytics and contacts; those are not a documented locally buildable site bundle. Our source/configuration can live in Git with reviews, history, and rollback. See [the build lifecycle](CONTRIBUTING.md#build-lifecycle) and [Linktree's export description](https://linktr.ee/features). |
| **Control the full generator and templates.** Change HTML, CSS, metadata, scripts, or rendering code. | Customization can go beyond the theme controls described by Linktree. This is source/template access, not a claim that our built-in design controls are richer. See [custom templates](README.md#custom-templates) and [Linktree's design options](https://linktr.ee/help/articles/5434140-an-overview-of-paid-features-available-on-linktree). |
| **Build locally and automate through a CLI or Perl API.** Generate pages from scripts and CI using files under your control. | A local build can run after dependencies are installed, including without network access when its inputs are local. The reviewed Linktree editing workflow uses its managed application. This does not imply that Linktree offers no automation interfaces. See [commands and the Perl API](README.md#commands-and-alternate-input-files). |
| **Choose the generator version.** Use a selected CPAN release or published Docker image, and retain the corresponding configuration and templates. | Operators can choose when to upgrade their generator. The reviewed Linktree service does not document a customer-pinned generator release. A pinned image digest identifies a specific container artifact; rebuilding against floating dependencies is not guaranteed to reproduce identical bytes. See [Docker usage](docker/README.md). |

These are useful differences even though they are less visible than a new
page widget. They particularly suit people who already maintain their sites
and configuration in Git.

## Shared features and important limits

- **GA4 and UTM tagging are not unique to us.** Linktree lists them under
  Pro/Premium in its [paid-feature guide](https://linktr.ee/help/articles/5434140-an-overview-of-paid-features-available-on-linktree).
  App::LinkSite makes its supported integrations available without a paid
  software tier. Hosting, domains, and external services may still have costs.
- **Self-hosted does not mean fully self-contained by default.** Generated
  pages reference Bootstrap and Font Awesome CDNs. Analytics and embedded
  services can add other external dependencies.
- **Choosing a hostname does not solve every hosting path.** Hosting at `/`
  works, but the default template uses root-relative asset URLs.
  Project/subpath support remains [issue #7](https://github.com/davorg-cpan/app-linksite/issues/7).
- **Source control is not a graphical editor.** Our flexibility currently
  requires editing JSON, templates, or code and managing deployment.

## Suggested priorities

The most useful additions for the current static-page model appear to be:

1. Link thumbnails and featured cards, especially for books and projects.
2. Header images and broader configuration for themes, fonts, and buttons.
3. Scheduled/expiring links paired with a documented rebuild schedule.

These are recommendations, not implemented features or a committed roadmap.
Social-link UTM support is separately recorded in issue #48. Recheck this
comparison against both products before turning a gap into implementation work.
