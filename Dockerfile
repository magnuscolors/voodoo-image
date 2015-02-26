FROM fgrehm/devstep:v0.3.0

USER root

RUN wget https://s3.amazonaws.com/akretion/packages/wkhtmltox-0.12.1_linux-trusty-amd64.deb && \
    dpkg -i wkhtmltox-0.12.1_linux-trusty-amd64.deb

RUN DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y libsasl2-dev bzr mercurial libxmlsec1-dev && \
    apt-get clean

RUN sed -i -e"s/^#fsync = on/fsync = off/g" /.devstep/addons/postgresql/conf/postgresql.conf

RUN mkdir -p /workspace && chown developer /workspace

RUN locale-gen pt_BR.UTF-8

USER developer

# Config for developer user
ADD stack/profile/voodoo.sh /.devstep/.profile.d/voodoo.sh
RUN mkdir -p /.devstep/.ssh
RUN mkdir /.devstep/.local && touch /.devstep/.viminfo

# Install postgresql
RUN /.devstep/bin/configure-addons postgresql

# Pre-build environement for odoo
ADD stack/build /workspace/
RUN sh /workspace/build_all

# Install ak cli
USER root
ADD stack/bin/ak /usr/local/bin/ak

USER developer

WORKDIR /workspace
