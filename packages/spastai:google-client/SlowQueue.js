/*
 * Slow downs the execution by limiting rate
 */
SlowQueue = function (context, delay) {
	var self = this;
	var actions = [];
	var timer = null;
	var active = false;
	var current = null;
		
	this.push = function(fn, cb) {
		//console.log("Pushing:"+fn);
		actions.push(fn.bind(context, cb));
	}

	this.start = function() {
		active = true;
		process();
	}

	this.pause = function(n) {
		// push dummy function
		actions.unshift(function() {});
	}
	
	this.repeat = function() {
		if(current)
			actions.unshift(current);
	}
	
	this.run = function(fn, cb) {
		self.push(fn, cb);
		process();
	}
	
	this.wrap = function(fn) {
		var args, context;
		return function() {
			context = this;
			args = [].slice.call(arguments);
			args.unshift(context);
			self.run(fn.bind.apply(fn, args));
		}
	};	
	
	function process() {
		if(active && !timer) {
			timer = setInterval(next, delay);
		}
	}
		
	function next() {
		current = actions.shift();
		if(current) {
			current.apply(context);
		} else {
			clearInterval(timer);
			timer = undefined;
		}		
	}
}

