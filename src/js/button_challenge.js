var createButtonChallengeModule = (() => {
  var _scriptName = typeof document != 'undefined' ? document.currentScript?.src : undefined;
  if (typeof __filename != 'undefined') _scriptName = _scriptName || __filename;
  return (
async function(moduleArg = {}) {
  var moduleRtn;

var b=moduleArg,f,h,k=new Promise((a,d)=>{f=a;h=d}),l="object"==typeof window,m="undefined"!=typeof WorkerGlobalScope,n="object"==typeof process&&"object"==typeof process.versions&&"string"==typeof process.versions.node&&"renderer"!=process.type,p=Object.assign({},b),q="",r,t;
if(n){var fs=require("fs");require("path");q=__dirname+"/";t=a=>{a=u(a)?new URL(a):a;return fs.readFileSync(a)};r=async a=>{a=u(a)?new URL(a):a;return fs.readFileSync(a,void 0)};process.argv.slice(2)}else if(l||m)m?q=self.location.href:"undefined"!=typeof document&&document.currentScript&&(q=document.currentScript.src),_scriptName&&(q=_scriptName),q.startsWith("blob:")?q="":q=q.slice(0,q.replace(/[?#].*/,"").lastIndexOf("/")+1),m&&(t=a=>{var d=new XMLHttpRequest;d.open("GET",a,!1);d.responseType=
"arraybuffer";d.send(null);return new Uint8Array(d.response)}),r=async a=>{if(u(a))return new Promise((g,c)=>{var e=new XMLHttpRequest;e.open("GET",a,!0);e.responseType="arraybuffer";e.onload=()=>{200==e.status||0==e.status&&e.response?g(e.response):c(e.status)};e.onerror=c;e.send(null)});var d=await fetch(a,{credentials:"same-origin"});if(d.ok)return d.arrayBuffer();throw Error(d.status+" : "+d.url);};b.print||console.log.bind(console);var v=b.printErr||console.error.bind(console);
Object.assign(b,p);p=null;var w=b.wasmBinary,x,y=!1,u=a=>a.startsWith("file://"),z=0,A=null,B;async function C(a){if(!w)try{var d=await r(a);return new Uint8Array(d)}catch{}if(a==B&&w)a=new Uint8Array(w);else if(t)a=t(a);else throw"both async and sync fetching of the wasm failed";return a}
async function D(a,d){try{var g=await C(a);return await WebAssembly.instantiate(g,d)}catch(c){throw v(`failed to asynchronously prepare wasm: ${c}`),a=c,b.onAbort?.(a),a="Aborted("+a+")",v(a),y=!0,a=new WebAssembly.RuntimeError(a+". Build with -sASSERTIONS for more info."),h(a),a;}}
async function E(a){var d=B;if(!w&&"function"==typeof WebAssembly.instantiateStreaming&&!u(d)&&!n)try{var g=fetch(d,{credentials:"same-origin"});return await WebAssembly.instantiateStreaming(g,a)}catch(c){v(`wasm streaming compile failed: ${c}`),v("falling back to ArrayBuffer instantiation")}return D(d,a)}var F=a=>{for(;0<a.length;)a.shift()(b)},G=[],H=[],I=()=>{var a=b.preRun.shift();H.unshift(a)},J={},K;
(async function(){function a(c){K=c.exports;x=K.a;c=x.buffer;b.HEAP8=new Int8Array(c);b.HEAP16=new Int16Array(c);b.HEAPU8=new Uint8Array(c);b.HEAPU16=new Uint16Array(c);b.HEAP32=new Int32Array(c);b.HEAPU32=new Uint32Array(c);b.HEAPF32=new Float32Array(c);b.HEAPF64=new Float64Array(c);b.HEAP64=new BigInt64Array(c);b.HEAPU64=new BigUint64Array(c);z--;b.monitorRunDependencies?.(z);0==z&&A&&(c=A,A=null,c());return K}z++;b.monitorRunDependencies?.(z);var d={a:J};if(b.instantiateWasm)return new Promise(c=>
{b.instantiateWasm(d,(e,M)=>{a(e,M);c(e.exports)})});B??=b.locateFile?b.locateFile("button_challenge.wasm",q):q+"button_challenge.wasm";try{var g=await E(d);return a(g.instance)}catch(c){return h(c),Promise.reject(c)}})();b._generate_position=a=>(b._generate_position=K.c)(a);b._is_near_target=(a,d,g,c)=>(b._is_near_target=K.d)(a,d,g,c);b._update_circle_position=(a,d,g,c,e)=>(b._update_circle_position=K.e)(a,d,g,c,e);
function L(){function a(){b.calledRun=!0;if(!y){K.b();f(b);b.onRuntimeInitialized?.();if(b.postRun)for("function"==typeof b.postRun&&(b.postRun=[b.postRun]);b.postRun.length;){var d=b.postRun.shift();G.unshift(d)}F(G)}}if(0<z)A=L;else{if(b.preRun)for("function"==typeof b.preRun&&(b.preRun=[b.preRun]);b.preRun.length;)I();F(H);0<z?A=L:b.setStatus?(b.setStatus("Running..."),setTimeout(()=>{setTimeout(()=>b.setStatus(""),1);a()},1)):a()}}
if(b.preInit)for("function"==typeof b.preInit&&(b.preInit=[b.preInit]);0<b.preInit.length;)b.preInit.pop()();L();moduleRtn=k;


  return moduleRtn;
}
);
})();
if (typeof exports === 'object' && typeof module === 'object') {
  module.exports = createButtonChallengeModule;
  // This default export looks redundant, but it allows TS to import this
  // commonjs style module.
  module.exports.default = createButtonChallengeModule;
} else if (typeof define === 'function' && define['amd'])
  define([], () => createButtonChallengeModule);
