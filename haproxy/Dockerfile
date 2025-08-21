#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM debian:trixie-slim

# runtime dependencies
RUN set -eux; \
	apt-get install --update -y --no-install-recommends \
# @system-ca: https://github.com/docker-library/haproxy/pull/216
		ca-certificates \
	; \
	apt-get dist-clean

# roughly, https://salsa.debian.org/haproxy-team/haproxy/-/blob/732b97ae286906dea19ab5744cf9cf97c364ac1d/debian/haproxy.postinst#L5-6
RUN set -eux; \
	groupadd --gid 99 --system haproxy; \
	useradd \
		--gid haproxy \
		--home-dir /var/lib/haproxy \
		--no-create-home \
		--system \
		--uid 99 \
		haproxy \
	; \
	mkdir /var/lib/haproxy; \
	chown haproxy:haproxy /var/lib/haproxy

ENV HAPROXY_VERSION 3.2.4
ENV HAPROXY_URL https://www.haproxy.org/download/3.2/src/haproxy-3.2.4.tar.gz
ENV HAPROXY_SHA256 5d4b2ee6fe56b8098ebb9c91a899d728f87d64cd7be8804d2ddcc5f937498c1d

# see https://sources.debian.net/src/haproxy/jessie/debian/rules/ for some helpful navigation of the possible "make" arguments
RUN set -eux; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	apt-get install --update -y --no-install-recommends \
		gcc \
		libc6-dev \
		liblua5.4-dev \
		libpcre2-dev \
		libssl-dev \
		make \
		wget \
	; \
	\
	wget -O haproxy.tar.gz "$HAPROXY_URL"; \
	echo "$HAPROXY_SHA256 *haproxy.tar.gz" | sha256sum -c; \
	mkdir -p /usr/src/haproxy; \
	tar -xzf haproxy.tar.gz -C /usr/src/haproxy --strip-components=1; \
	rm haproxy.tar.gz; \
	\
	makeOpts=' \
		TARGET=linux-glibc \
		USE_GETADDRINFO=1 \
		USE_LUA=1 LUA_INC=/usr/include/lua5.4 \
		USE_OPENSSL=1 \
		USE_PCRE2=1 USE_PCRE2_JIT=1 \
		USE_PROMEX=1 \
	'; \
# https://salsa.debian.org/haproxy-team/haproxy/-/commit/53988af3d006ebcbf2c941e34121859fd6379c70
	dpkgArch="$(dpkg --print-architecture)"; \
	case "$dpkgArch" in \
		armel) makeOpts="$makeOpts ADDLIB=-latomic" ;; \
	esac; \
	\
	nproc="$(nproc)"; \
	eval "make -C /usr/src/haproxy -j '$nproc' all $makeOpts"; \
	eval "make -C /usr/src/haproxy install-bin $makeOpts"; \
	\
	mkdir -p /etc/haproxy; \
	cp -R /usr/src/haproxy/examples/errorfiles /etc/haproxy/errors; \
	rm -rf /usr/src/haproxy; \
	\
	apt-mark auto '.*' > /dev/null; \
	[ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; \
	find /usr/local -type f -executable -exec ldd '{}' ';' \
		| awk '/=>/ { so = $(NF-1); if (index(so, "/usr/local/") == 1) { next }; gsub("^/(usr/)?", "", so); printf "*%s\n", so }' \
		| sort -u \
		| xargs -r dpkg-query --search \
		| cut -d: -f1 \
		| sort -u \
		| xargs -r apt-mark manual \
	; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	apt-get dist-clean; \
	\
# smoke test
	haproxy -v

# https://www.haproxy.org/download/1.8/doc/management.txt
# "4. Stopping and restarting HAProxy"
# "when the SIGTERM signal is sent to the haproxy process, it immediately quits and all established connections are closed"
# "graceful stop is triggered when the SIGUSR1 signal is sent to the haproxy process"
STOPSIGNAL SIGUSR1

RUN update-ca-certificates
RUN chmod 777 /etc/ssl/certs/ca-certificates.crt
ADD haproxy/dataplaneapi.yml /etc/haproxy/dataplaneapi.yml
ADD haproxy/docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh / # backwards compat
RUN apt update -y && apt install -y git lua5.4 liblua5.4-dev argon2 libargon2-dev luarocks
RUN git config --global url."https://".insteadOf git://
RUN luarocks install --lua-version 5.4 argon2 ARGON2_DIR=/usr ARGON2_LIBDIR=/usr/lib/x86_64-linux-gnu

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["haproxy", "-f", "/etc/haproxy/haproxy.cfg"]
