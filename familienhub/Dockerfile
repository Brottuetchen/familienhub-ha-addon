# Add-on image: the published Familienhub image plus a start script.
# The Supervisor passes the add-on version as BUILD_VERSION, which is also the image tag.
# The default below is only used for manual builds; keep it equal to "version" in config.yaml.
ARG BUILD_VERSION=1.0.0-beta.3
FROM ghcr.io/brottuetchen/familienhub:${BUILD_VERSION}

# The upstream image runs as UID 10001, but /data of an add-on belongs to root.
# The start script fixes ownership of /data and then drops to UID 10001.
USER root
COPY run.sh /run.sh
RUN chmod 0755 /run.sh

# Working directory (/app/backend) and the HEALTHCHECK are inherited from the upstream image.
CMD ["/run.sh"]
