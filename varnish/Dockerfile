FROM varnish:latest

COPY start.sh /start.sh

ENV VARNISHLOG=true \
    VARNISHLOG_OPTS="-g session"

CMD ["/start.sh"]
