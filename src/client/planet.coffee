class Planet
	constructor: (planet) ->
		@pos = planet.pos
		@hitRadius = planet.hitRadius
		@force = planet.force

	draw: (ctxt, offset = {x: 0, y: 0}) ->
		px = @pos.x + offset.x
		py = @pos.y + offset.y
		f = @force;

		# Check the planet really needs to be drawn.
		if not inView(px+f, py+f) and
				not inView(px+f, py-f) and
				not inView(px-f, py+f) and
				not inView(px-f, py-f)
			return

		x = px - view.x
		y = py - view.y

		if showHitCircles
			ctxt.strokeStyle = 'red'
			ctxt.lineWidth = 1
			strokeCircle(ctxt, x, y, @hitRadius)

		ctxt.strokeStyle = color planetColor
		ctxt.fillStyle = color planetColor
		ctxt.lineWidth = 4
		ctxt.beginPath()
		ctxt.arc x, y, f, 0, 2*Math.PI, false
		ctxt.stroke()
