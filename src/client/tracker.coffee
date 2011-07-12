class Tracker
	constructor: (tracker) ->
		@serverUpdate(tracker)

	serverUpdate: (tracker) ->
		state_old = @state

		for field, val of tracker
			this[field] = val

		@explode() if state_old isnt @state and @state is 'dead'

	update: () ->
		@clientDelete = @serverDelete

	draw: (ctxt, offset = {x: 0, y: 0}) ->
		return if @state is 'dead'

		ctxt.save()
		ctxt.translate(@pos.x, @pos.y)
		ctxt.rotate(@dir)
		@drawModel(ctxt, color(@color))
		ctxt.restore()

	drawHitbox: (ctxt) ->
		ctxt.strokeStyle = 'red'
		ctxt.lineWidth = 1
		strokeCircle(ctxt, @pos.x, @pos.y, @hitRadius)

	drawModel: (ctxt, col) ->
		hr = @hitRadius

		ctxt.fillStyle = color @color
		ctxt.strokeStyle = color @color
		ctxt.lineWidth = 2

		ctxt.save()
		ctxt.scale(0.7, 1)

		# Draw the hull.
		ctxt.beginPath()
		ctxt.moveTo(-hr, hr)
		ctxt.lineTo(-hr, -hr)
		ctxt.quadraticCurveTo(2*hr, -hr, 3*hr, 0)
		ctxt.quadraticCurveTo(2*hr, hr, -hr, hr)
		ctxt.stroke()

		# Draw the central wing.
		ctxt.fillRect(-hr, -1, 1.5*hr, 2)

		# Draw the lateral wings.
		drawWing = (ctxt, hr) ->
			ctxt.beginPath()
			ctxt.moveTo(-hr, -hr)
			ctxt.lineTo(-hr, -2*hr)
			ctxt.lineTo(hr, -hr)
			ctxt.fill()

		drawWing(ctxt, hr)
		ctxt.scale(1, -1)
		drawWing(ctxt, hr)
		
		ctxt.restore()

	inView: (offset = {x:0, y:0}) ->
		window.boxInView(@pos.x + offset.x,
			@pos.y + offset.y, @hitRadius)

	explode: () ->
		window.effects.push new ExplosionEffect(@pos, @color, 100, 5, 0.2)

# Exports
window.Tracker = Tracker
