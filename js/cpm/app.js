var restify = require('restify');
var plugins = require('restify-plugins')

var path = require("path");
var scriptName = path.basename(__filename);
var log4js = require("log4js");
var logger = log4js.getLogger(scriptName);

var cpm = require("./pool");
var config = require("./config.json");

var server = restify.createServer({
    name : "CPM"
});

logger.level = config.trace;

logger.info("started");
server.use(plugins.queryParser());
server.use(plugins.bodyParser({mapParams: true}));

// REST defination
var PATH = '/paas/service/apaas/api/v1.1/apps'
server.get ({path : PATH +'/:identityDomainId/:appId' , version : '0.0.1'} , rest_GetTaskStatus);
server.post({path : PATH +'/:identityDomainId', version: '0.0.1'} ,rest_createNewApp);
server.post({path : PATH +'/:identityDomainId/:appId/start' , version: '0.0.1'} ,rest_startApp);
server.del ({path : PATH +'/:identityDomainId/:appId' , version: '0.0.1'} ,rest_deleteApp);

// For test
server.post({path : PATH +'/:identityDomainId/testload', version: '0.0.1'} ,rest_testLoad);

cpm.Init(config);

server.listen(config.port , config.host, function(){
    console.log('%s listening at %s ', server.name , server.url);
}); 

function rest_createNewApp(req , res , next){
    console.log('==== rest_createNewApp ==== [' + 'domainid=' + req.params.identityDomainId + ' title=' + req.params.title);

    var app = {};
	app = cpm.AllocateApp(req, res)

    res.setHeader('Access-Control-Allow-Origin','*'); 
    res.send(201 , app);

	return next();
}

function rest_deleteApp(req , res , next){
    console.log('==== rest_deleteApp ==== [' + 'domainid=' + req.params.identityDomainId + "  appId=" + req.params.appId + ']');

	var app = {};
	app = cpm.FreeApp(req, res);

    res.setHeader('Access-Control-Allow-Origin','*');
	res.send(204, app);
	return next();
}

function rest_startApp(req , res , next){
    console.log('==== rest_startApp ==== [' + 'domainid=' + req.params.identityDomainId + "  appId=" + req.params.appId + ']');

    var app = {}; 
	app = cpm.StartTask(req, res);

    res.setHeader('Access-Control-Allow-Origin','*'); 
    res.send(201 , app);
	return next();
}

function rest_GetTaskStatus(req, res , next){
    console.log('==== rest_GetTaskStatus ==== [' + 'domainid=' + req.params.identityDomainId + "  appId=" + req.params.appId + ']');

    var app = {}; 
	app = cpm.GetTaskStatus(req, res);

    res.setHeader('Access-Control-Allow-Origin','*');
    res.send(200 , app);
	return next();
}

////////////////////////////////////////////////////////////////////////////////////////
// FOR TEST
function rest_testLoad(req , res , next){
    console.log('==== rest_testLoad ==== [' + 'domainid=' + req.params.identityDomainId + ']');
    var app = {};

    app.title = req.params.title;
    app.description = req.params.description;
    app.location = req.params.location;
    app.postedOn = new Date();

    res.setHeader('Access-Control-Allow-Origin','*'); 

var async = require('async'); 
var http = require('http'); 
/*
var task = []; 
task.push(function(callback){ 
 console.time('访问3个网站时间统计'); 
var options = {
      host: 'cn-proxy.jp.oracle.com',
      port: '80',
	  method: 'GET', 
      path: 'http://www.baidu.com', //full URL i.e. www.google.com/?q=testing+1+2+3
      headers: {}
    }
 http.request(options, function(res) {  
  console.log("百度访问结果: " + res.statusCode); 
  setTimeout(function() { 
   callback(null); 
  }, 5000); 
 }).on('error', function(e) {  
  console.log("百度访问结果: " + e.message); 
  callback(e); 
 }); 
}) 

task.push(function(callback){ 
 http.get('http://www.youku.com/', function(res) {  
  console.log("优酷访问结果: " + res.statusCode); 
  setTimeout(function() { 
   callback(null); 
  }, 10000); 
 }).on('error', function(e) { 
  console.log("优酷访问结果: " + e.message); 
  callback(e); 
 }); 
}) 
  
task.push(function(callback){ 
 http.get('http://www.qq.com/', function(res) {  
  console.log("腾讯访问结果: " + res.statusCode); 
  callback(null); 
 }).on('error', function(e) {  
  console.log("腾讯访问结果: " + e.message); 
  callback(e); 
 }); 
}) 
  
async.waterfall(task, function(err,result){ 
 console.timeEnd('访问3个网站时间统计'); 
 if(err) return console.log(err); 
 console.log('全部访问成功'); 
})
*/

/*
	sleep(10 * 1000);
    res.send(201 , app);
*/

var opt = {
  host: 'cn-proxy.jp.oracle.com',
  port: '80',
 method:'GET',
 path:'http://www.baidu.com',
 headers:{
  'Content-Type': 'application/x-www-form-urlencoded'
 }
}
var body = '';
//var req2 = http.request(opt, function(res2) {
var req2 = http.get("http://bej301738.cn.oracle.com:16002/paas/service/apaas/api/v1.1/apps/sleep", function(res2) {
  console.log("Got res2ponse: " + res2.statusCode);
  res2.on('data',function(d){
  body += d;
 }).on('end', function(){
  console.log(res2.headers)
  console.log(body)
    res.send(201 , app);
/*
  setTimeout(function() { 
  	console.log('sleep end');
    res.send(201 , app);
  }, 20*1000); */
 }); 
}).on('error', function(e) {
  console.log("Got error: " + e.message);
})
req2.end(); 
    //res.send(201 , app);
	return next();
}

