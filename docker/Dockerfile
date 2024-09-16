FROM perl:latest
LABEL maintainer="dave@perlhacks.org"

COPY . /links
RUN cd /links && cpanm --installdeps .
RUN mkdir /linkdir
ENV PATH "$PATH:/links/bin"
ENV PERL5LIB /links/lib
WORKDIR /linksdir
