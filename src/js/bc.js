var createButtonChallengeModule = (() => {
  var _scriptName = typeof document != 'undefined' ? document.currentScript?.src : undefined;
  if (typeof __filename != 'undefined') _scriptName = _scriptName || __filename;
  return (
async function(moduleArg = {}) {
  var moduleRtn;

var b=moduleArg,f,h,k=new Promise((a,d)=>{f=a;h=d}),l="object"==typeof window,m="undefined"!=typeof WorkerGlobalScope,p="object"==typeof process&&"object"==typeof process.versions&&"string"==typeof process.versions.node&&"renderer"!=process.type,q=Object.assign({},b),t="",u;
if(p){var fs=require("fs");require("path");t=__dirname+"/";u=a=>{a=v(a)?new URL(a):a;return fs.readFileSync(a)};process.argv.slice(2)}else if(l||m)m?t=self.location.href:"undefined"!=typeof document&&document.currentScript&&(t=document.currentScript.src),_scriptName&&(t=_scriptName),t.startsWith("blob:")?t="":t=t.slice(0,t.replace(/[?#].*/,"").lastIndexOf("/")+1),m&&(u=a=>{var d=new XMLHttpRequest;d.open("GET",a,!1);d.responseType="arraybuffer";d.send(null);return new Uint8Array(d.response)});
b.print||console.log.bind(console);var w=b.printErr||console.error.bind(console);Object.assign(b,q);q=null;var x=b.wasmBinary,y,z=!1,v=a=>a.startsWith("file://"),A=0,B=null;async function C(){if(x)var a=new Uint8Array(x);else if(a="data:application/octet-stream;base64,AGFzbQEAAAABGQRgAABgBX9/f39/AGAEf39/fwF/YAF/AX8DBQQAAQIDBAUBcAEBAQUGAQGCAoICBxkGAWECAAFiAAABYwADAWQAAgFlAAEBZgEACl8EAgALFgAgACACIARrNgIAIAEgAyAEazYCAAsYACAAIAJqIgAgASADa04gACABIANqTHELKgEBfkGACEGACCkDAEKt/tXk1IX9qNgAfkIBfCIBNwMAIAFCIYinIABvCw==".startsWith("data:application/octet-stream;base64,")?D("data:application/octet-stream;base64,AGFzbQEAAAABGQRgAABgBX9/f39/AGAEf39/fwF/YAF/AX8DBQQAAQIDBAUBcAEBAQUGAQGCAoICBxkGAWECAAFiAAABYwADAWQAAgFlAAEBZgEACl8EAgALFgAgACACIARrNgIAIAEgAyAEazYCAAsYACAAIAJqIgAgASADa04gACABIANqTHELKgEBfkGACEGACCkDAEKt/tXk1IX9qNgAfkIBfCIBNwMAIAFCIYinIABvCw==".slice(37)):void 0,!a)if(u)a=u("data:application/octet-stream;base64,AGFzbQEAAAABGQRgAABgBX9/f39/AGAEf39/fwF/YAF/AX8DBQQAAQIDBAUBcAEBAQUGAQGCAoICBxkGAWECAAFiAAABYwADAWQAAgFlAAEBZgEACl8EAgALFgAgACACIARrNgIAIAEgAyAEazYCAAsYACAAIAJqIgAgASADa04gACABIANqTHELKgEBfkGACEGACCkDAEKt/tXk1IX9qNgAfkIBfCIBNwMAIAFCIYinIABvCw==");else throw"both async and sync fetching of the wasm failed";return a}
async function E(a){try{var d=await C();return await WebAssembly.instantiate(d,a)}catch(e){throw w(`failed to asynchronously prepare wasm: ${e}`),a=e,b.onAbort?.(a),a="Aborted("+a+")",w(a),z=!0,a=new WebAssembly.RuntimeError(a+". Build with -sASSERTIONS for more info."),h(a),a;}}async function F(a){return E(a)}
for(var G=a=>{for(;0<a.length;)a.shift()(b)},H=[],I=[],J=()=>{var a=b.preRun.shift();I.unshift(a)},D=a=>{if(p)return a=Buffer.from(a,"base64"),new Uint8Array(a.buffer,a.byteOffset,a.length);for(var d,e,c=0,g=0,n=a.length,r=new Uint8Array((3*n>>2)-("="==a[n-2])-("="==a[n-1]));c<n;c+=4,g+=3)d=K[a.charCodeAt(c+1)],e=K[a.charCodeAt(c+2)],r[g]=K[a.charCodeAt(c)]<<2|d>>4,r[g+1]=d<<4|e>>2,r[g+2]=e<<6|K[a.charCodeAt(c+3)];return r},K=new Uint8Array(123),L=25;0<=L;--L)K[48+L]=52+L,K[65+L]=L,K[97+L]=26+L;
K[43]=62;K[47]=63;var M={},N;
(async function(){function a(c){N=c.exports;y=N.a;c=y.buffer;b.HEAP8=new Int8Array(c);b.HEAP16=new Int16Array(c);b.HEAPU8=new Uint8Array(c);b.HEAPU16=new Uint16Array(c);b.HEAP32=new Int32Array(c);b.HEAPU32=new Uint32Array(c);b.HEAPF32=new Float32Array(c);b.HEAPF64=new Float64Array(c);b.HEAP64=new BigInt64Array(c);b.HEAPU64=new BigUint64Array(c);A--;b.monitorRunDependencies?.(A);0==A&&B&&(c=B,B=null,c());return N}A++;b.monitorRunDependencies?.(A);var d={a:M};if(b.instantiateWasm)return new Promise(c=>{b.instantiateWasm(d,
(g,n)=>{a(g,n);c(g.exports)})});try{var e=await F(d);return a(e.instance)}catch(c){return h(c),Promise.reject(c)}})();b._generate_position=a=>(b._generate_position=N.c)(a);b._is_near_target=(a,d,e,c)=>(b._is_near_target=N.d)(a,d,e,c);b._update_circle_position=(a,d,e,c,g)=>(b._update_circle_position=N.e)(a,d,e,c,g);
function O(){function a(){b.calledRun=!0;if(!z){N.b();f(b);b.onRuntimeInitialized?.();if(b.postRun)for("function"==typeof b.postRun&&(b.postRun=[b.postRun]);b.postRun.length;){var d=b.postRun.shift();H.unshift(d)}G(H)}}if(0<A)B=O;else{if(b.preRun)for("function"==typeof b.preRun&&(b.preRun=[b.preRun]);b.preRun.length;)J();G(I);0<A?B=O:b.setStatus?(b.setStatus("Running..."),setTimeout(()=>{setTimeout(()=>b.setStatus(""),1);a()},1)):a()}}
if(b.preInit)for("function"==typeof b.preInit&&(b.preInit=[b.preInit]);0<b.preInit.length;)b.preInit.pop()();O();moduleRtn=k;


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
