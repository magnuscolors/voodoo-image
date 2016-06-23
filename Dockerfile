FROM ubuntu:16.04

USER root

RUN DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y libsasl2-dev bzr mercurial libxmlsec1-dev python-pip graphviz \
    python-cups python-dbus python-openssl python-libxml2 wkhtmltopdf xfonts-base \
    xfonts-75dpi npm git postgresql-client wget libpq-dev libjpeg8-dev libldap2-dev && \
    npm install -g less less-plugin-clean-css && \
    ln -sf /usr/bin/nodejs /usr/bin/node && \
    apt-get clean

RUN locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8 && \
    DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales

RUN pip install --upgrade pip && \
    pip install flake8 && \
    pip install --upgrade git+https://github.com/oca/pylint-odoo.git && \
    pip install pgcli && \
    pip install git+https://github.com/akretion/ak.git@v2

#Install fonts
ADD stack/fonts/c39hrp24dhtt.ttf /usr/share/fonts/c39hrp24dhtt.ttf
RUN chmod a+r /usr/share/fonts/c39hrp24dhtt.ttf && fc-cache -f -v

RUN mkdir -p /workspace

# Pre-build environement for odoo
ADD stack/build /workspace/
RUN sh /workspace/build_all

RUN pip install git+https://github.com/akretion/ak.git@v2 --upgrade

# Pre-build for tests
# TODO reimplement using https://github.com/akretion/voodoo/pull/33/files 
#RUN sh /workspace/build_tests

## Config for developer user
#ADD stack/profile/voodoo.sh /home/devstep/.profile.d/voodoo.sh
#RUN mkdir -p /home/devstep/.ssh
#RUN mkdir /home/devstep/.local && touch /home/devstep/.viminfo

WORKDIR /workspace
