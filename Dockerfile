FROM ubuntu:16.04

USER root

RUN DEBIAN_FRONTEND=noninteractive && \
    apt update && \
    apt install -y libsasl2-dev bzr mercurial libxmlsec1-dev python-pip graphviz && \
    apt install -y python-cups python-dbus python-openssl python-libxml2 && \
    apt install wkhtmltopdf && \
    apt install -y xfonts-base xfonts-75dpi npm && \
    npm install -g less less-plugin-clean-css && \
    ln -sf /usr/bin/nodejs /usr/bin/node && \
    apt-get clean && \

RUN locale-gen pt_BR.UTF-8

RUN pip install flake8 && \
    pip install --upgrade git+https://github.com/oca/pylint-odoo.git
    pip install pgcli

#Install fonts
ADD stack/fonts/c39hrp24dhtt.ttf /usr/share/fonts/c39hrp24dhtt.ttf
RUN chmod a+r /usr/share/fonts/c39hrp24dhtt.ttf && fc-cache -f -v

RUN mkdir -p /workspace && chown developer /workspace

# Pre-build environement for odoo
ADD stack/build /workspace/
RUN sh /workspace/build_all

# Pre-build for tests
# TODO reimplement using https://github.com/akretion/voodoo/pull/33/files 
#RUN sh /workspace/build_tests

## Config for developer user
#ADD stack/profile/voodoo.sh /home/devstep/.profile.d/voodoo.sh
#RUN mkdir -p /home/devstep/.ssh
#RUN mkdir /home/devstep/.local && touch /home/devstep/.viminfo

WORKDIR /workspace
