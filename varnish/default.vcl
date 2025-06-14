vcl 4.1;
import std;

# backend pointing to HAProxy
backend default {
	.path = "/shared-sockets/varnish-to-haproxy-internal.sock";
}
backend haproxy {
	.path = "/shared-sockets/varnish-to-haproxy-internal.sock";
}

acl purge_allowed {
	"127.0.0.1";
	"::1";
	"103.230.159.7";
	"2404:9400:2:0:216:3eff:fee3:5c06";
}

sub vcl_pipe {
	return (pipe);
}

# custom simpler synth() template
sub vcl_synth {
    set resp.http.Content-Type = "text/plain; charset=utf-8";
    set resp.body = "" + resp.status + " " + resp.reason;
    return (deliver);
}

# incoming requests
sub vcl_recv {

	# route all requests to haproxy
	set req.backend_hint = haproxy;

	# unfuck x-forwarded-for
	if (req.http.X-Forwarded-For) {
		set req.http.X-Forwarded-For = regsub(req.http.X-Forwarded-For, "^([^,]+),?.*$", "\1");
	} else {
		# set fallback to client IP
		set req.http.X-Forwarded-For = client.ip;
	}

	# handle PURGE and BAN
	if ((req.method == "PURGE" || req.method == "BAN") && req.http.X-BasedFlare-Varnish-Key == "changeme") {
		if (std.ip(req.http.X-Forwarded-For, "0.0.0.0") ~ purge_allowed) {
			#perform action based on the request method
			if (req.method == "PURGE") {
				return (purge);
			} else if (req.method == "BAN") {
				ban("obj.http.x-url ~ ^" + req.http.X-BasedFlare-Purge-Url + ".*" + " && obj.http.x-host == " + req.http.X-BasedFlare-Purge-Host);
				return (synth(200, "Banned " + "obj.http.x-url ~ ^" + req.http.X-BasedFlare-Purge-Url + ".*" + " && obj.http.x-host == " + req.http.X-BasedFlare-Purge-Host));
			}
		} else {
			return (synth(405, "Not allowed"));
		}
	}

	if (req.http.Range) {
		return (pass);
	}

	# some conditions are not cached (done in haproxy also, might be redundant)
	if (req.method != "GET" && req.method != "HEAD") {
		# pass through for non-GET requests
		return (pass);
	}

	# honor cache control headers for "no-cache" or "no-store"
	if (req.http.Cache-Control ~ "no-cache" || req.http.Cache-Control ~ "no-store" || req.url ~ "\.m3u8$") {
		return (pass);
	}

}

sub vcl_hash {
	hash_data(req.url);
	if (req.http.Host) {
		hash_data(req.http.Host);
	}
	if (req.http.Range) {
		hash_data(req.http.Range);
	}
}

## caching behavior when fetching from backend
sub vcl_backend_response {

	set beresp.http.x-url = bereq.url; # Set for ban lurker
	set beresp.http.x-host = bereq.http.host; # Set for ban lurker

	set beresp.do_stream = true;  # Stream directly
	set beresp.transit_buffer = 1M; # testing

	# dont cache > 100MB
	if (beresp.http.Content-Length && std.integer(beresp.http.Content-Length, 0) > 100 * 1024 * 1024) {
		set beresp.uncacheable = true;  # Don't cache
		return (deliver);
	}

	# dont cache set-cookie responses
	if (beresp.http.Set-Cookie) {
		set beresp.uncacheable = true;
		return (pass);
	}

	# dont cache ranges
	# if (bereq.http.Range) {
	# 	set beresp.ttl = 0s;
	# 	set beresp.uncacheable = true;
	# }

	# only cache specific types of content and successful responses
	if ((beresp.status == 200 || beresp.status == 206) && (!beresp.http.Content-Type || beresp.http.Content-Type ~ "text|application|image|video|audio|font")) {
		if (beresp.http.Cache-Control ~ "no-cache" || beresp.http.Cache-Control ~ "no-store" || beresp.http.Pragma == "no-cache") {
			#don't cache if the backend says no-cache
			set beresp.uncacheable = true;
			return (pass);
		} else if (beresp.http.Cache-Control ~ "max-age") {
			# use max-age if provided
			set beresp.ttl = std.duration(regsub(beresp.http.Cache-Control, ".*max-age=([0-9]+).*", "\1") + "s", 0s);
		} else if (beresp.http.Expires) {
			# calculate ttl using Expires if present
			set beresp.ttl = std.duration(beresp.http.Expires + "s", 0s);
		} else {
			# default ttl if no cache header
			set beresp.ttl = 1m;
			set beresp.uncacheable = true;
			return (pass);
		}
		# grace period for stale content
		set beresp.grace = 10m;
		set beresp.uncacheable = false;
	} else {
		# non-cacheable or non-success responses
		set beresp.uncacheable = true;
		return (pass);
	}

}

# when sending response
sub vcl_deliver {

	unset resp.http.x-url; # Unset what we set for ban lurker
	unset resp.http.x-host; # Unset what we set for ban lurker

	# add accept-ranges for backend reqs
	if (req.http.Range) {
		set resp.http.Accept-Ranges = "bytes";
	}

	# custom header to indicate cache hit or miss
	if (obj.hits > 0) {
		set resp.http.X-Cache = "HIT";
	} else {
		set resp.http.X-Cache = "MISS";
	}

}
