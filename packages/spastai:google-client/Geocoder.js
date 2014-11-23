Geocoder = function () {
	
	this.googleSteam = new SlowQueue(this, 500);

	this.init = function(geocoder) {
		this.geocoder = geocoder;
		this.googleSteam.start();
	}

	/**
	 * query: { 'address': address}
	 */
	this.geocode = this.googleSteam.wrap(function(query, callback) {
		var self = this;
		this.geocoder.geocode(query, function(results, status) {
	        if (status == google.maps.GeocoderStatus.OK) {
	        	//console.log("Success for:"+JSON.stringify(query))
	        	callback(null, results);
	        } else if(status == google.maps.GeocoderStatus.OVER_QUERY_LIMIT) {
	        	//console.log("Repeating for:"+JSON.stringify(query))
	        	self.googleSteam.pause();
	        	self.googleSteam.repeat();
	        	callback(status);
	        } else if(status == google.maps.GeocoderStatus.ZERO_RESULTS) {
	        	console.log("Zero result:"+JSON.stringify(query))
	        	callback(status);
	        } else {
	        	//console.log("Failed:"+JSON.stringify(query))
	        	e("Geocode failed for:"+JSON.stringify(query), status);
	      		callback(status);
	        }
	    });	
	});
}