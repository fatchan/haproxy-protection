FROM alpine:latest
RUN apk update && apk add tor
RUN chmod -R 700 /var/lib/tor/
RUN chown -R tor /var/lib/tor/
RUN chown -R tor /etc/tor
COPY ./tor/entrypoint.sh /usr/local/bin/start_tor.sh
RUN chmod +x /usr/local/bin/start_tor.sh
USER tor
ENTRYPOINT [ "/usr/local/bin/start_tor.sh" ]
