FROM fgrehm/devstep:v0.2.0

USER root

RUN wget https://s3.amazonaws.com/akretion/packages/wkhtmltox-0.12.1_linux-trusty-amd64.deb && \
    dpkg -i wkhtmltox-0.12.1_linux-trusty-amd64.deb

RUN DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y python-pip libsasl2-dev python-bzrlib python-pip bzr mercurial && \
    apt-get clean


RUN mkdir /.devstep/.local && chown developer /.devstep/.local && \
    touch /.devstep/.viminfo && chown developer /.devstep/.viminfo

RUN sed -i -e"s/^#fsync = on/fsync = off/g" /.devstep/addons/postgresql/conf/postgresql.conf

RUN mkdir -p /workspace && chown developer /workspace
WORKDIR /workspace

ADD requirements.txt /workspace/requirements.txt
RUN pip install pip --upgrade
RUN pip install setuptools --upgrade
RUN pip install -r requirements.txt

USER developer

RUN /.devstep/bin/configure-addons postgresql


RUN wget https://raw.github.com/buildout/buildout/master/bootstrap/bootstrap.py
RUN wget https://gist.githubusercontent.com/rvalyi/db890269f9c8353a101e/raw/edbfa0b6dcac55e4b5176b0a70ec9102a0b94b9a/buildout.dockerfile.cfg && \
    python bootstrap.py --allow-site-packages -c buildout.dockerfile.cfg

RUN wget -O- https://gist.githubusercontent.com/rvalyi/0dd63c06310095836062/raw/b1deab1217afc07379fe629c61c976a4c3222837/fake_odoo7 | sh && \
    cd /workspace && python bin/buildout -c buildout.dockerfile.cfg && \
    rm -rf /workspace/parts && rm -rf /workspace/etc && rm /workspace/upgrade.py

RUN wget -O- https://gist.githubusercontent.com/rvalyi/9ac3a22cde339aa1ef35/raw/4dac97154c62e31c366f42273a084f143d10fc1e/fake_odoo8 | sh && \
    cd /workspace && python bin/buildout -c buildout.dockerfile.cfg && \
    rm -rf /workspace/parts && rm -rf /workspace/etc && rm /workspace/upgrade.py

RUN mkdir /.devstep/addons/voodoo && \
    mv /workspace/eggs /.devstep/addons/voodoo/eggs && \
    mv /workspace/develop-eggs /.devstep/addons/voodoo/develop-eggs && \
    mv /workspace/downloads /.devstep/addons/voodoo/downloads && \
    rm /workspace/bootstrap.py && \
    rm /workspace/requirements.txt

USER root

RUN wget https://gist.githubusercontent.com/rvalyi/4e62a50aaef186b85970/raw/5ba7be8be4faf82405cf3c3f28133d3d5ae2fd0f/init1 && \
    mv init1 /.devstep/.profile.d/voodoo.sh && chmod +x /.devstep/.profile.d/voodoo.sh

RUN ln -s /workspace/ak /bin/ak

RUN wget -O- https://gist.githubusercontent.com/rvalyi/4bcc33f1e4f7b0c31a7c/raw/84f4d6b144c2421534c05338ffc35c12a78637b3/gistfile1.txt
RUN wget -O- https://gist.githubusercontent.com/rvalyi/287cd8b05611b9ef92a2/raw/8056b3041c61c48612e2b3f4c575f387a5c74fa3/gistfile1.txt

USER developer
