//var restify = require('restify');

/*
AllocateApp()
StartTask({appName})
FreeApp({appName})
GetTaskStatus({appName})
Startup phase (not API)
*/

exports.Init = function(config) { 
    console.log('==== Init(config.DefaultContainerNum=' + config.DefaultContainerNum  + ',config.MaxContainerNum' + config.MaxContainerNum + ')');
	return true;
};
exports.Clean = function(config) { 
    console.log('==== Clean(config.DefaultContainerNum=' + config.DefaultContainerNum  + ',config.MaxContainerNum' + config.MaxContainerNum + ')');
	return true;
};
exports.AllocateApp = function(req , res) { 
    var app = {};
    console.log('==== AllocateApp(' + req.params.identityDomainId+ ')');
	var d = new Date();
	app.appId=d.toString();
	return app;
};
exports.FreeApp = function(req , res) { 
    var app = {};
    console.log('==== FreeApp(' + req.params.identityDomainId+ ',' + req.params.appId + ')');
	app.dumy_result="Free_OK"
	return app;
};
exports.StartTask = function(req , res) { 
    var app = {};
    console.log('==== StartTask(' + req.params.identityDomainId+ ',' + req.params.appId + ')');
	app.dumy_result="Start_OK"
	return app;
};
exports.GetTaskStatus = function(req , res) { 
    var app = {};
    console.log('==== GetTaskStatus(' + req.params.identityDomainId+ ',' + req.params.appId + ')');
	app.dumy_result="GetTaskStatus_OK"
	return app;
};

//just for test
exports.sleep=function(milliSeconds) { 
    console.log('==== sleep(' + milliSeconds + ')');
    var startTime = new Date().getTime(); 
    while (new Date().getTime() < startTime + milliSeconds);
	return;
};
