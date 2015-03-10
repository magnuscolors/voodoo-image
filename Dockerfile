FROM fgrehm/devstep:v0.3.0

USER root

RUN wget https://s3.amazonaws.com/akretion/packages/wkhtmltox-0.12.1_linux-trusty-amd64.deb && \
    dpkg -i wkhtmltox-0.12.1_linux-trusty-amd64.deb

RUN DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y libsasl2-dev bzr mercurial libxmlsec1-dev python-pip graphviz && \
    apt-get clean && \
    pip install pgcli

RUN sed -i -e"s/^#fsync = on/fsync = off/g" /opt/devstep/addons/postgresql/conf/postgresql.conf

RUN sed -i -e"s/postgres/developer/g" /home/devstep/.profile.d/postgresql.sh

RUN mkdir -p /workspace && chown developer /workspace

RUN locale-gen pt_BR.UTF-8

# force postgresql install due to this bug https://github.com/fgrehm/devstep/pull/91
RUN DEBIAN_FRONTEND=noninteractive && apt-get install -y postgresql

USER developer

# Config for developer user
ADD stack/profile/voodoo.sh /home/devstep/.profile.d/voodoo.sh
RUN mkdir -p /home/devstep/.ssh
RUN mkdir /home/devstep/.local && touch /home/devstep/.viminfo

# Install postgresql
RUN /opt/devstep/bin/configure-addons postgresql

# Pre-build environement for odoo
ADD stack/build /workspace/
RUN sh /workspace/build_all

# Install ak cli
USER root
ADD stack/bin/ak /usr/local/bin/ak

USER developer

WORKDIR /workspace
