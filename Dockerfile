FROM fgrehm/devstep:v0.4.0

USER root

RUN DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y libsasl2-dev bzr mercurial libxmlsec1-dev python-pip graphviz && \
    apt-get install -y python-cups python-dbus python-openssl python-libxml2 && \
    apt-get install -y xfonts-base xfonts-75dpi npm && \
    npm install -g less less-plugin-clean-css && \
    ln -s /usr/bin/nodejs /usr/bin/node && \
    apt-get clean && \
    pip install pgcli

RUN wget http://download.gna.org/wkhtmltopdf/0.12/0.12.1/wkhtmltox-0.12.1_linux-trusty-amd64.deb && \
    dpkg -i wkhtmltox-0.12.1_linux-trusty-amd64.deb

RUN sed -i -e"s/^#fsync = on/fsync = off/g" /opt/devstep/addons/postgresql/conf/postgresql.conf

RUN sed -i -e"s/postgres/developer/g" /home/devstep/.profile.d/postgresql.sh

RUN mkdir -p /workspace && chown developer /workspace

RUN locale-gen pt_BR.UTF-8

RUN pip install flake8 && \
    pip install pylint

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

# Pre-build for tests
RUN sh /workspace/build_tests

# Install ak cli
USER root
ADD stack/bin/ak /usr/local/bin/ak

#Install fonts
ADD stack/fonts/c39hrp24dhtt.ttf /usr/share/fonts/c39hrp24dhtt.ttf
RUN chmod a+r /usr/share/fonts/c39hrp24dhtt.ttf && fc-cache -f -v

USER developer

WORKDIR /workspace
