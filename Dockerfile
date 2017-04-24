FROM akretion/voodoo

USER root

RUN DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y python-cups && \
    apt-get clean

USER odoo
