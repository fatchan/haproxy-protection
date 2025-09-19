local _M = {}

local extra_head_tags = ""
local extra_head_css = "body,html,:root{font-family:'Segoe UI', Tahoma, Geneva, Verdana, sans-serif}"
if os.getenv("USE_INTER_FONT") then
	extra_head_tags = [[
		<link rel='preconnect' href='https://rsms.me/'>
		<link rel='stylesheet' href='https://rsms.me/inter/inter.css'>
	]]
	extra_head_css = [[
		:root { font-family: 'Inter', sans-serif; }
		@supports (font-variation-settings: normal) {
			:root { font-family: 'Inter var', sans-serif; }
		}
	]]
end

if os.getenv("USE_POSTHOG") then
    extra_head_tags = extra_head_tags .. [[
	    <script>
	        !function(t,e){var o,n,p,r;e.__SV||(window.posthog=e,e._i=[],e.init=function(i,s,a){function g(t,e){var o=e.split(".");2==o.length&&(t=t[ o[0] ],e=o[1]),t[e]=function(){t.push([e].concat(Array.prototype.slice.call(arguments,0)))}}(p=t.createElement("script")).type="text/javascript",p.crossOrigin="anonymous",p.async=!0,p.src=s.api_host.replace(".i.posthog.com","-assets.i.posthog.com")+"/static/array.js",(r=t.getElementsByTagName("script")[0]).parentNode.insertBefore(p,r);var u=e;for(void 0!==a?u=e[a]=[]:a="posthog",u.people=u.people||[],u.toString=function(t){var e="posthog";return"posthog"!==a&&(e+="."+a),t||(e+=" (stub)"),e},u.people.toString=function(){return u.toString(1)+".people (stub)"},o="init me ws ys ps bs capture je Di ks register register_once register_for_session unregister unregister_for_session Ps getFeatureFlag getFeatureFlagPayload isFeatureEnabled reloadFeatureFlags updateEarlyAccessFeatureEnrollment getEarlyAccessFeatures on onFeatureFlags onSurveysLoaded onSessionId getSurveys getActiveMatchingSurveys renderSurvey canRenderSurvey canRenderSurveyAsync identify setPersonProperties group resetGroups setPersonPropertiesForFlags resetPersonPropertiesForFlags setGroupPropertiesForFlags resetGroupPropertiesForFlags reset get_distinct_id getGroups get_session_id get_session_replay_url alias set_config startSessionRecording stopSessionRecording sessionRecordingStarted captureException loadToolbar get_property getSessionProperty Es $s createPersonProfile Is opt_in_capturing opt_out_capturing has_opted_in_capturing has_opted_out_capturing clear_opt_in_out_capturing Ss debug xs getPageViewId captureTraceFeedback captureTraceMetric".split(" "),n=0;n<o.length;n++)g(u,o[n]);e._i.push([i,s,a])},e.__SV=1)}(document,window.posthog||[]);
	        posthog.init('phc_XFjuHiLYlVq2XQ8lwEiuaN36NFPkP7cxOrBNqiqYOv1', {
	            api_host: 'https://us.i.posthog.com',
	            person_profiles: 'identified_only', // or 'always' to create profiles for anonymous users as well
	        })
	    </script>
    ]]
end

-- main page template
local body_css = [[:root{--text-color:#c5c8c6;--bg-color:#1d1f21}@media (prefers-color-scheme:light){:root{--text-color:#333;--bg-color:#fff}}.g-recaptcha,.h-captcha{min-height:85px;display:block}.red{display:inline-block;color:#ff0000d0;background:#ff000020;border:1px solid #ff000050;font-weight:bold;padding:12px;border-radius:6px}.left{text-align:left}.powstatus{color:#6b93f7;font-size:small}a,a:visited{color:var(--text-color)}body,html{height:100%%;text-align:center}body{display:flex;flex-direction:column;background-color:var(--bg-color);color:var(--text-color);max-width:60em;margin:0 auto;padding:0 20px}details{max-width:1200px;text-align:left;border-left:2px solid #ff0000d0;padding:10px}code{background-color:#dfdfdf30;border-radius:4px;padding:0 3px;color:#ff6590}h3,img{margin:0 0 16px}li{margin-bottom:1em}footer{font-size:x-small;margin-top:auto;padding:10px;text-align:center;border-top:1px solid #80808040;padding:10px;max-width:300px;margin:auto auto 0}img{display:inline}input,textarea{background:var(--bg-color);color:var(--text-color);border:1px solid var(--text-color);width:100%%;box-sizing:border-box;resize:none;padding:5px;margin:5px;font-family:inherit;border-radius:6px}input[type="submit"]{padding:8px}.pt{padding-top:25vh;word-wrap:break-word;display:flex;flex-direction:column}.pt img{margin:0 auto 10px}.b{display:inline-block;border-radius:50%%;margin:20px 12px;height:16px;width:16px;transform:scale(1);box-shadow:0 0 0 0 #6b93f720;background:#6b93f7;--shadow1:#6b93f790;--shadow2:#6b93f700;--shadow3:#6b93f700}.b.green{background:#31cc31;box-shadow:0 0 0 0 #31cc3120;--shadow1:#31cc3190;--shadow2:#31cc3100;--shadow3:#31cc3100}.b:nth-of-type(1){animation:p 3s infinite}.b:nth-of-type(2){animation:p 3s 0.5s infinite}.b:nth-of-type(3){animation:p 3s 1s infinite}details:not([open]),summary{cursor:pointer}@keyframes p{0%%{transform:scale(.95);box-shadow:0 0 0 0 var(--shadow1)}70%%{transform:scale(1);box-shadow:0 0 0 8px var(--shadow2)}100%%{transform:scale(.95);box-shadow:0 0 0 0 var(--shadow3)}}details summary::-webkit-details-marker,details summary::marker{display:none}details summary{list-style-type:none}details[open] > summary:before{transform:rotate(90deg)}summary{padding-left:20px}summary:before{content:'';border-width:8px;border-style:solid;border-color:transparent transparent transparent var(--text-color);position:absolute;transform:rotate(0);transform-origin:4px 50%%;transition:0.25s transform ease;margin:3px 0 0 -15px}#captcha{margin-top:1em}canvas{display:flex;margin:0 auto;cursor:pointer;background:lightgray;border:2px solid black;border-radius:5px;}]]
_M.body = string.format([[
<!DOCTYPE html>
<html>
	<head lang='%%s' data-langjson='%%s'>
		%s
		<meta name='viewport' content='width=device-width initial-scale=1'>
		<title>%%s</title>
		<style>
%s
%s
		</style>
		<link rel='stylesheet' href='data:text/css;charset=utf-8,%%s'>
		<noscript>
			<style>.jsonly{display:none}</style>
		</noscript>
		%%s
		<script src="/.basedflare/js/argon2.min.js"></script>
		<script src="/.basedflare/js/challenge.min.js"></script>
	</head>
	<body data-pow="%%s" data-diff="%%s" data-time="%%s" data-kb="%%s" data-mode="%%s">
		<h3 class="pt">
			<img src="/.basedflare/pow-icon" width="64" height="64" alt=" ">
			%%s
		</h3>
		%%s
		%%s
		<noscript>
			<br>
			<div class="red">%%s</div>
			%%s
		</noscript>
		<div class="powstatus"></div>
		<canvas id="canvas" width="250" height="40"></canvas>
		<footer>
			<p>Node: <code>%%s</code></p>
			<p>%%s</p>
		</footer>
	</body>
</html>
]], extra_head_tags, extra_head_css, body_css)

_M.noscript_extra_argon2 = [[
			<details>
				<summary>%s</summary>
				<ol>
					<li>
						<p>%s</p>
						<code style="word-break: break-all;">
							echo "Q0g9IiQyIjtCPSQocHJpbnRmIDAlLjBzICQoc2VxIDEgJDUpKTtlY2hvICJXb3JraW5nLi4uIjtJPTA7d2hpbGUgdHJ1ZTsgZG8gSD0kKGVjaG8gLW4gJENIJEkgfCBhcmdvbjIgJDEgLWlkIC10ICQ2IC1rICQ3IC1wIDEgLWwgMzIgLXIpO0U9JHtIOjA6JDV9O1tbICRFID09ICRCIF1dICYmIGVjaG8gIk91dHB1dDoiICYmIGVjaG8gJDEjJDIjJDMjJDQjJEkgJiYgZXhpdCAwOygoSSsrKSk7ZG9uZTsK" | base64 -d | bash -s %s %s %s %s %s %s %s
						</code>
					<li>%s
					<form method="post">
						<textarea name="pow_response" required></textarea>
						<div><input type="submit" value="submit" /></div>
					</form>
				</ol>
			</details>
]]

_M.noscript_extra_sha256 = [[
			<details>
				<summary>%s</summary>
				<ol>
					<li>
						<p>%s</p>
						<code style="word-break: break-all;">
							echo "dXNlIHN0cmljdDt1c2UgRGlnZXN0OjpTSEEgcXcoc2hhMjU2X2hleCk7cHJpbnQgIldvcmtpbmcuLi4iO215JGM9IiRBUkdWWzBdIi4iJEFSR1ZbMV0iO215JGlkPSRBUkdWWzRdKzA7bXkkZD0iMCJ4JGlkO215JGk9MDt3aGlsZSgxKXtsYXN0IGlmICRkIGVxIHN1YnN0ciBzaGEyNTZfaGV4KCRjLCRpKSwwLCRpZDskaSsrfXByaW50IlxuT3V0cHV0OlxuJEFSR1ZbMF0jJEFSR1ZbMV0jJEFSR1ZbMl0jJEFSR1ZbM10jJGlcbiI=" | base64 -d | perl -w - %s %s %s %s %s %s %s
						</code>
					<li>%s
					<form method="post">
						<textarea name="pow_response" required></textarea>
						<div><input type="submit" value="submit" /></div>
					</form>
				</ol>
			</details>
]]

-- animation while waiting
_M.pow_section = [[
		<span>
			%s
		</span>
		<div class="jsonly">
			<div id="loader"><div class="b"></div><div class="b"></div><div class="b"></div></div>
		</div>
]]

-- captcha section
local captcha_sitekey = os.getenv("HCAPTCHA_SITEKEY") or os.getenv("RECAPTCHA_SITEKEY")
local captcha_classname = ""
local captcha_script_src = ""
if os.getenv("HCAPTCHA_SITEKEY") then
	captcha_classname = "h-captcha"
	captcha_script_src = "https://hcaptcha.com/1/api.js"
else
	captcha_classname = "g-recaptcha"
	captcha_script_src = "https://www.google.com/recaptcha/api.js"
end
_M.captcha_section = string.format([[
		<span>
			%%s
		</span>
		<div id="captcha" class="jsonly">
			<div class="%s" data-sitekey="%s" data-callback="onCaptchaSubmit"></div>
			<script src="%s" async defer></script>
		</div>
]], captcha_classname, captcha_sitekey, captcha_script_src)

return _M
