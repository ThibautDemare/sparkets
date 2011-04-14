function Planet(planet) {
	this.pos = planet.pos;
	this.force = planet.force;
}

Planet.prototype = {

	draw : function(offset) {
		if(offset == undefined)
			offset = {x : 0, y : 0};

		var x = this.pos.x - view.x + offset.x;
		var y = this.pos.y - view.y + offset.y;

		ctxt.strokeStyle = color(planetColor);
		ctxt.beginPath();
		ctxt.arc(x, y, this.force, 0, 2*Math.PI, false);
		ctxt.stroke();
	}
};