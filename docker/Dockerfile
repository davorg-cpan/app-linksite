FROM perl:latest
LABEL maintainer="dave@davecross.co.uk"

ARG LINKSITE_VERSION
ARG BUILD_DATE
ARG GIT_COMMIT

LABEL org.opencontainers.image.title="App::LinkSite"
LABEL org.opencontainers.image.description="Minimal link site generator in Perl"
LABEL org.opencontainers.image.version="${LINKSITE_VERSION}"
LABEL org.opencontainers.image.created="${BUILD_DATE}"
LABEL org.opencontainers.image.revision="${GIT_COMMIT}"
LABEL org.opencontainers.image.authors="Dave Cross <dave@davecross.co.uk>"
LABEL org.opencontainers.image.source="https://github.com/davorg/app-linksite"
LABEL org.opencontainers.image.licenses="Artistic-1.0-Perl OR GPL-1+"

RUN cpanm -n App::LinkSite@${LINKSITE_VERSION}
RUN mkdir /links
WORKDIR /links

CMD ["perl", "-MApp::LinkSite", "-E", "say $App::LinkSite::VERSION"]

