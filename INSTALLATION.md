#### Environment variables

For development/testing in docker, these are in docker-compose.yml.

For production, add them to your haproxy environment file. On Debian/Ubuntu with systemd, the default EnvironmentFile is typically `/etc/default/haproxy`.

- HCAPTCHA_SITEKEY - your hcaptcha site key
- HCAPTCHA_SECRET - your hcaptcha secret key
- RECAPTCHA_SITEKEY - your recaptcha site key
- RECAPTCHA_SECRET - your recaptcha secret key
NOTE: Use either hcaptcha or recaptcha, not both.

- CAPTCHA_COOKIE_SECRET - random string, a salt for captcha cookies
- POW_COOKIE_SECRET - different random string, a salt for pow cookies
- HMAC_COOKIE_SECRET - different random string, a salt for pow cookies
- TOR_CONTROL_PORT_PASSWORD - the control port password for tor daemon
- RAY_ID - string to identify the HAProxy node by
- BACKEND_NAME - name of backend to insert servers from hosts.map
- SERVER_PREFIX - prefix of server names used in the backend
- VERIFY_BACKEND_SSL - whether to use ssl to connect to backends
- VERIFY_BACKEND_SSL_VERYFYNONE - whether to ignore invalid certificates when using ssl connections to backends
- CHALLENGE_EXPIRY - how long solution cookies last for, in seconds
- CHALLENGE_INCLUDES_IP - whether to lock solved challenges to IP or tor circuit identifier
- ARGON_TIME - default argon2 iterations
- ARGON_KB - default argon2 memory usage in KB
- POW_DIFFICULTY - default pow difficulty
- POW_TYPE - default hash algorithm for pow "argon2" or "sha256"
- USE_INTER_FONT - use a remote font on the bot-check pages
- USE_POSTHOG - add posthog script for session recording to the bot-check pages (for remote debugging)

#### Run in docker (for testing/development)

Run docker compose:
```bash
docker compose up
```

Visit http://localhost

#### Installation

Requires HAProxy >=3.0 compiled with lua support. For Debian-based distros and/or Ubuntu, see https://haproxy.debian.net/ for packages.

- Clone the repo somewhere. `/var/www/haproxy-protection` works.
- Copy [haproxy.cfg](haproxy/haproxy.cfg) to `/etc/haproxy/haproxy.cfg`.
- Copy/link [scripts](src/lua/scripts) to `/etc/haproxy/scripts`.
- Copy/link [libs](src/lua/libs) to `/etc/haproxy/libs`.
- Copy/link [template](haproxy/template) to `/etc/haproxy/template`.
- Copy/link [js](src/js) to `/etc/haproxy/js`.
- Copy the [map files](haproxy/map) to `/etc/haproxy/map`.
- Install argon2, and the lua argon2 module with luarocks:
```bash
sudo apt install -y git lua5.4 liblua5.4-dev argon2 libargon2-dev luarocks 
sudo git config --global url."https://".insteadOf git:// #don't ask.
sudo luarocks install argon2
# optionally, if you have issues;
sudo luarocks install --lua-version 5.4 argon2
sudo luarocks install --lua-version 5.4 argon2 ARGON2_DIR=/usr ARGON2_LIBDIR=/usr/lib/x86_64-linux-gnu
```

NOTE: the provided configuration is an example and will work for testing and development. You are expected to tune values or otherwise copy the relevant parts into your own haproxy config.

If you have problems, read the error messages before opening an issue that is simply a bad configuration.

#### Use with a Tor .onion

- Change the `bind` line in `haproxy.cfg`. Switch to the one with `accept-proxy`.
- To generate a tor control port password:
```
$ tor --hash-password example
16:0175C41DDD88C5EA605582C858BC08FA29014215F233479A99FE78EDED
```
- Set `TOR_CONTROL_PORT_PASSWORD` env var to the same password (NOT the output hash)
- Add to your torrc (where xxxx is the output of `tor --hash-password`):
```
ControlPort 9051
HashedControlPassword xxxxxxxxxxxxxxxxx
```
- Restart tor
