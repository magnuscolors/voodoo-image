FROM fgrehm/devstep:v0.1.0

USER root

RUN wget https://s3.amazonaws.com/akretion/packages/wkhtmltox-0.12.1_linux-trusty-amd64.deb && \
    dpkg -i wkhtmltox-0.12.1_linux-trusty-amd64.deb

RUN DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y python-pip libsasl2-dev python-passlib python-bzrlib python-pip bzr mercurial && \
    apt-get clean && \
    pip install setuptools --upgrade && \
    pip install zc.buildout


RUN mkdir /.devstep/.local && chown developer /.devstep/.local && \
    touch /.devstep/.viminfo && chown developer /.devstep/.viminfo

RUN cd /.devstep && \
    wget https://gist.githubusercontent.com/rvalyi/ca48cf7b7e8df92fd9e0/raw/0539f2925093a99202ec2f215c2ca8230568bb3f/devstep-pg3 && \
    patch -p0 < devstep-pg3 && \
    sed -i -e"s/^#fsync = on/fsync = off/g" /.devstep/addons/postgresql/conf/postgresql.conf

RUN mkdir -p /workspace && chown developer /workspace
WORKDIR /workspace

USER developer

RUN /.devstep/bin/configure-addons postgresql


ADD bootstrap.py /workspace/bootstrap.py
ADD buildout.cfg /workspace/buildout.cfg
ADD modules /workspace/modules
RUN wget https://gist.githubusercontent.com/rvalyi/db890269f9c8353a101e/raw/1664d5e2dce889ff1bb7e435c7ff083542f6b4c7/buildout.dockerfile.cfg && \
    python bootstrap.py --allow-site-packages


RUN wget -O- https://gist.githubusercontent.com/rvalyi/0dd63c06310095836062/raw/b1deab1217afc07379fe629c61c976a4c3222837/fake_odoo7 | sh && \
    cd /workspace && python bin/buildout -c buildout.dockerfile.cfg && \
    rm -rf /workspace/parts && rm -rf /workspace/etc && rm /workspace/upgrade.py

RUN wget -O- https://gist.githubusercontent.com/rvalyi/9ac3a22cde339aa1ef35/raw/4dac97154c62e31c366f42273a084f143d10fc1e/fake_odoo8 | sh && \
    cd /workspace && python bin/buildout -c buildout.dockerfile.cfg && \
    rm -rf /workspace/parts && rm -rf /workspace/etc && rm /workspace/upgrade.py

RUN mkdir /.devstep/addons/voodoo
RUN mv /workspace/eggs /.devstep/addons/voodoo/eggs
RUN mv /workspace/develop-eggs /.devstep/addons/voodoo/develop-eggs
RUN mv /workspace/downloads /.devstep/addons/voodoo/downloads


USER root

RUN wget https://gist.githubusercontent.com/rvalyi/4e62a50aaef186b85970/raw/5ba7be8be4faf82405cf3c3f28133d3d5ae2fd0f/init1 && \
    mv init1 /.devstep/.profile.d/voodoo.sh && chmod +x /.devstep/.profile.d/voodoo.sh

RUN ln -s /workspace/ak /bin/ak

RUN wget -O- https://gist.githubusercontent.com/rvalyi/fb2f76ef3ed07d796771/raw/76822a8acd679dcb12465a23cc808b22f13fd981/gistfile1.txt | sh

RUN wget -O- https://gist.githubusercontent.com/rvalyi/19a759ca0ee1fe24fb52/raw/b01dc47e9793eeb0db24ae64ae889ce214fbc978/gistfile1.txt | sh

USER developer
