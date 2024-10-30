FROM perl:latest
LABEL maintainer="dave@davecross.co.uk"

ARG USERNAME=links
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME

RUN cpanm -n App::LinkSite@0.0.3
RUN mkdir /links
WORKDIR /links

RUN chown $USERNAME:$USERNAME /links

USER $USERNAME
