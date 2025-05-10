# 🌐 Basedflare (haproxy-protection)

HAProxy configuration and lua scripts allowing a challenge-response page where users solve a captcha and/or proof-of-work. Intended to stop bots, spam, ddos, etc.

**Available as a managed service 👉 [Basedflare.com](https://basedflare.com)**

![demo](demo.gif "demo")

---

#### Installation

See [INSTALLATION.md](INSTALLATION.md)

#### Features:

- Proof-of-work and/or captcha challenge.
  - Choice of argon2 or sha256 proof of work.
  - Support for hcaptcha or recaptcha.
- Automatically solves new challenges in the background to prevent interruption during long browsing sessions.
- Shares POW answers with storage events to prevent extra work when opening multiple tabs.
- Supports .onion/tor with the PROXY protocol, using circuit identifiers as a substitute for IPs.
- Allow users without javascript to solve the POW by providing a shell script and html form inside `noscript` tags.
- Use HAProxy `http-request return` to directly serve challenge files from the edge without a separate backend.
- Adjustable cookie validity lifetime.
- Adjustable protection mode per domain or domain+path.
- Option to add custom values into challenge hashes (e.g. TLS fingerprints)
- Multiple language (currently en-US, pt-PT, pt-BR).
- Manage everything through a web based control panel during runtime ([fatchan/haproxy-panel-next](https://gitgud.io/fatchan/haproxy-panel-next)).

---

#### For generous people

Bitcoin (BTC): [`bc1q4elrlz5puak4m9xy3hfvmpempnpqpu95v8s9m6`](bitcoin:bc1q4elrlz5puak4m9xy3hfvmpempnpqpu95v8s9m6)

Monero (XMR): [`89J9DXPLUBr5HjNDNZTEo4WYMFTouSsGjUjBnUCCUxJGUirthnii4naZ8JafdnmhPe4NP1nkWsgcK82Uga7X515nNR1isuh`](monero:89J9DXPLUBr5HjNDNZTEo4WYMFTouSsGjUjBnUCCUxJGUirthnii4naZ8JafdnmhPe4NP1nkWsgcK82Uga7X515nNR1isuh)
