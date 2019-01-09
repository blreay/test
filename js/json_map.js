function strMapToObj(strMap) {
    let obj = Object.create(null);
    for (let [k,v] of strMap) { obj[k] = v; }
    return obj;
} 
function objToStrMap(obj) {
    let strMap = new Map();
    for (let k of Object.keys(obj)) { strMap.set(k, obj[k]); }
    return strMap;
} 
function strMapToJson(strMap) {
    return JSON.stringify(strMapToObj(strMap));
} 
function jsonToStrMap(jsonStr) {
    return objToStrMap(JSON.parse(jsonStr));
}

let myMap = new Map().set('yes', true).set('no', false);
console.log(strMapToObj(myMap))
console.log(objToStrMap({yes: true, no: false}))

let myMap2 = new Map().set('yes', true).set('no', false);
console.log(strMapToJson(myMap2))
console.log(jsonToStrMap('{"yes":true,"no":false}'))

jsonstr='{"cert_key1":{"AKI":"AAABBB","revoke_date":"20180101_122253"}, "cert_key2":{"AKI":"BBBCCC","revoke_date":"20180101_122254"}}'
//console.log(jsonstr)
//console.log("zzy01:" + JSON.parse(jsonstr).id3.cid1)
let jsonmap=jsonToStrMap(jsonstr)
console.log("Convert JSON to map:" + jsonmap)
console.log(jsonmap)
console.log("Get revoke date:" + jsonmap.get("cert_key2").revoke_date)
let strfrommap=strMapToJson(jsonmap)
console.log("Convert map to JSON:" + strfrommap)

// for merge
jsonstr2='{"cert_key2":{"AKI":"AAABBB","revoke_date":"20180101_122253"}, "cert_key3":{"AKI":"BBBCCC","revoke_date":"20180101_122254"}}'
let jsonmap2=jsonToStrMap(jsonstr2)
for (var [key, value] of jsonmap2) {
  console.log(key + ' = ' + value);
  jsonmap.set(key, value);
} 
console.log(jsonmap)

//exp=undefined
if(typeof(exp) == undefined){
     console.log("undefined1");
}
if(typeof(exp) == "undefined"){
     console.log("undefined");
}
if(typeof(exp) == 'undefined'){
     console.log("undefined");
}
if(exp1 == undefined){
     console.log("undefined0");
}
