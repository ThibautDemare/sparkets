function Bullet(owner) {
	this.owner = owner;
	this.pos = { x : owner.pos.x,
	             y : owner.pos.y };

	this.power = owner.firePower;

	this.accel = { x : 10*this.power*Math.sin(owner.dir),
	               y : -10*this.power*Math.cos(owner.dir) };

	this.color = owner.color;
	this.points = [[this.pos.x, this.pos.y]];

	if (owner.id === ship.id)
		this.send();

	this.dead = false;
}

Bullet.prototype = {

	send : function() {
		socket.send({ type: 'bullet',
		              playerId: this.owner.id,
		              firePower : this.power });
	},

	draw : function(alpha, offset) {
		if(offset == undefined)
			offset = {x : 0, y : 0};

		var points = this.points;

		ctxt.strokeStyle = color(this.color, alpha);
		ctxt.beginPath();

		ctxt.moveTo(points[0][0] - view.x + offset.x, points[0][1] - view.y + offset.y);
		for (var i=1, len=points.length; i < len; ++i)
			ctxt.lineTo(points[i][0] - view.x + offset.x, points[i][1] - view.y + offset.y);

		ctxt.stroke();
	},

	step : function() {
		if (this.dead)
			return;

		// Compute new position from acceleration and gravity of all
		// planets.
		var x = this.pos.x;
		var y = this.pos.y;
		
		var ax = this.accel.x;
		var ay = this.accel.y;

		planets.forEach(function(p) {
			var d = (p.pos.x-x)*(p.pos.x-x) + (p.pos.y-y)*(p.pos.y-y);
			var d2 = 200 * p.force / (d * Math.sqrt(d));

			ax -= (x-p.pos.x) * d2;
			ay -= (y-p.pos.y) * d2;
		});

		var nx = x + ax;
		var ny = y + ay;

		this.points.push([nx, ny]);

		this.pos.x = nx;
		this.pos.y = ny;
		
		this.accel.x = ax;
		this.accel.y = ay;

		// warp the bullet around the map
		this.pos.x = this.pos.x < 0 ? map.w : this.pos.x;
		this.pos.x = this.pos.x > map.w ? 0 : this.pos.x;
		this.pos.y = this.pos.y < 0 ? map.h : this.pos.y;
		this.pos.y = this.pos.y > map.h ? 0 : this.pos.y;

		this.checkCollisions();
	},

	checkCollisions : function() {
		var x = this.pos.x;
		var y = this.pos.y;
		var os;
		if (collideWithShip(x,y)) {
			ship.explode();
			this.dead = true;
		}
		else if (os = collideWithOtherShip(x,y)) {
			os.explode();
			this.dead = true;
		}
		else if (collideWithPlanet(x,y)) {
			this.dead = true;
		}
		else if (this.outOfBounds()) {
			this.dead = true;
		}
	},

	outOfBounds : function() {
		var x = this.pos.x;
		var y = this.pos.y;
		return x < 0 || x > map.w || y < 0 || y > map.h;
	}
};