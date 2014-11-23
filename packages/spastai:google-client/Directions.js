Directions = function () {
	
	this.googleSteam = new SlowQueue(this, 500);

	this.init = function(directions) {
		this.directions = directions;
		this.googleSteam.start();
	}

	/**
	 * query: { 'address': address}
	 */
	this.route = this.googleSteam.wrap(function(query, callback) {
		var self = this;
		this.directions.route(query, function(results, status) {
	        if (status == google.maps.DirectionsStatus.OK) {
	        	//console.log("Success for:"+JSON.stringify(query))
	        	callback(null, results);
	        } else if(status == google.maps.DirectionsStatus.OVER_QUERY_LIMIT) {
	        	//console.log("Repeating for:"+JSON.stringify(query))
	        	self.googleSteam.pause();
	        	self.googleSteam.repeat();
	        } else {
	         	//console.log("Failed:"+JSON.stringify(query))
	        	e("Service failed for:"+JSON.stringify(query), status);
	      		callback(status);
	        }
	    });	
	});
}