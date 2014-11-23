/**
 * Is counting how many actions are running at same time 
 */
ParallelQueue = function (context) {
	var self = this;
	var active = 0;
	this.finalCallback;
	var actions = [];
	
	this.run = function(fn) {
		actions.push(fn);
	};
	
	this.start = function() {
		this.run = executeNow
		for(i in actions) {
			actions[i]();
		}
	}

	function executeNow(fn) {
		fn()
	};	
	
	this.wrap = function(fn) {
		var args;
		return function() {
			active++;
			//context = this;
			args = [].slice.call(arguments);
			var callback = args.pop();
			if(callback && (typeof callback != 'function')) {
				// it's just an argument
				args.push(callback);
				callback = undefined;
			} 
			args.push(function() {
				callback && callback.apply(this, [].slice.call(arguments))
				if(--active == 0) {
					self.finalCallback && self.finalCallback()
				}
			});
//			args.unshift(context); // check ; 
//			self.run(fn.bind.apply(fn, args));
			self.run(fn.bind.apply(fn, [context].concat(args)));

		}
	};	
		
	this.purge = function(fn) {
		this.finalCallback = fn;
		this.start();
	}
};