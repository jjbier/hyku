FROM solr:8.11 as hyku-solr
ENV SOLR_USER="solr" \
    SOLR_GROUP="solr"
USER root
COPY --chown=solr:solr security.json /var/solr/data/security.json
USER $SOLR_USER
