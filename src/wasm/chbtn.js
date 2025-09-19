
var createChallengeModule = (() => {
  var _scriptName = typeof document != 'undefined' ? document.currentScript?.src : undefined;
  if (typeof __filename != 'undefined') _scriptName = _scriptName || __filename;
  return (
function(moduleArg = {}) {
  var moduleRtn;

var a=moduleArg,e,g,h=new Promise((b,c)=>{e=b;g=c}),k="object"==typeof window,l="undefined"!=typeof WorkerGlobalScope,m="object"==typeof process&&"object"==typeof process.versions&&"string"==typeof process.versions.node&&"renderer"!=process.type,n=Object.assign({},a),p="",q;
if(m){var fs=require("fs"),r=require("path");p=__dirname+"/";q=b=>{b=t(b)?new URL(b):r.normalize(b);return fs.readFileSync(b)};process.argv.slice(2)}else if(k||l)l?p=self.location.href:"undefined"!=typeof document&&document.currentScript&&(p=document.currentScript.src),_scriptName&&(p=_scriptName),p.startsWith("blob:")?p="":p=p.substr(0,p.replace(/[?#].*/,"").lastIndexOf("/")+1),l&&(q=b=>{var c=new XMLHttpRequest;c.open("GET",b,!1);c.responseType="arraybuffer";c.send(null);return new Uint8Array(c.response)});
a.print||console.log.bind(console);var u=a.printErr||console.error.bind(console);Object.assign(a,n);n=null;var v=a.wasmBinary,w,x=!1,y=[],z=[],A=[];function B(){var b=a.preRun.shift();y.unshift(b)}var C=0,D=null,E=null,F=b=>b.startsWith("data:application/octet-stream;base64,"),t=b=>b.startsWith("file://"),G;
function H(){var b=G;return Promise.resolve().then(()=>{if(b==G&&v)var c=new Uint8Array(v);else{if(F(b))if(c=b.slice(37),"undefined"!=typeof m&&m)c=Buffer.from(c,"base64"),c=new Uint8Array(c.buffer,c.byteOffset,c.length);else{c=atob(c);for(var d=new Uint8Array(c.length),f=0;f<c.length;++f)d[f]=c.charCodeAt(f);c=d}else c=void 0;if(!c)if(q)c=q(b);else throw"both async and sync fetching of the wasm failed";}return c})}
function I(b,c){return H().then(d=>WebAssembly.instantiate(d,b)).then(c,d=>{u(`failed to asynchronously prepare wasm: ${d}`);a.onAbort?.(d);d="Aborted("+d+")";u(d);x=!0;d=new WebAssembly.RuntimeError(d+". Build with -sASSERTIONS for more info.");g(d);throw d;})}function J(b,c){return I(b,c)}
var K=b=>{for(;0<b.length;)b.shift()(a)},L={},M=function(){function b(d){M=d.exports;w=M.a;d=w.buffer;a.HEAP8=new Int8Array(d);a.HEAP16=new Int16Array(d);a.HEAPU8=new Uint8Array(d);a.HEAPU16=new Uint16Array(d);a.HEAP32=new Int32Array(d);a.HEAPU32=new Uint32Array(d);a.HEAPF32=new Float32Array(d);a.HEAPF64=new Float64Array(d);z.unshift(M.b);C--;a.monitorRunDependencies?.(C);0==C&&(null!==D&&(clearInterval(D),D=null),E&&(d=E,E=null,d()));return M}var c={a:L};C++;a.monitorRunDependencies?.(C);if(a.instantiateWasm)try{return a.instantiateWasm(c,
b)}catch(d){u(`Module.instantiateWasm callback failed with error: ${d}`),g(d)}G??="data:application/octet-stream;base64,AGFzbQEAAAABGQRgAABgBX9/f39/AGAEf39/fwF/YAF/AX8DBQQAAQIDBAUBcAEBAQUGAQGCAoICBxkGAWECAAFiAAABYwADAWQAAgFlAAEBZgEACl8EAgALFgAgACACIARrNgIAIAEgAyAEazYCAAsYACAAIAJqIgAgASADa04gACABIANqTHELKgEBfkGACEGACCkDAEKt/tXk1IX9qNgAfkIBfCIBNwMAIAFCIYinIABvCw==";J(c,function(d){b(d.instance)}).catch(g);return{}}();a._cstart_size=b=>(a._cstart_size=M.c)(b);a._outline_color=(b,c,d,f)=>(a._outline_color=M.d)(b,c,d,f);a._increment_position=(b,c,d,f,P)=>(a._increment_position=M.e)(b,c,d,f,P);var N;E=function O(){N||Q();N||(E=O)};
function Q(){function b(){if(!N&&(N=!0,a.calledRun=!0,!x)){K(z);e(a);a.onRuntimeInitialized?.();if(a.postRun)for("function"==typeof a.postRun&&(a.postRun=[a.postRun]);a.postRun.length;){var c=a.postRun.shift();A.unshift(c)}K(A)}}if(!(0<C)){if(a.preRun)for("function"==typeof a.preRun&&(a.preRun=[a.preRun]);a.preRun.length;)B();K(y);0<C||(a.setStatus?(a.setStatus("Running..."),setTimeout(()=>{setTimeout(()=>a.setStatus(""),1);b()},1)):b())}}
if(a.preInit)for("function"==typeof a.preInit&&(a.preInit=[a.preInit]);0<a.preInit.length;)a.preInit.pop()();Q();moduleRtn=h;


  return moduleRtn;
}
);
})();
if (typeof exports === 'object' && typeof module === 'object')
  module.exports = createChallengeModule;
else if (typeof define === 'function' && define['amd'])
  define([], () => createChallengeModule);
