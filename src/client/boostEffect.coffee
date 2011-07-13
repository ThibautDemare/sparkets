class BoostEffect
	constructor: (@object, @density = 3, @duration = 1000) ->
		@shadows = []
		@updates = 0

		@running = yes
		setTimeout( (() => @running = no), @duration)

	update: () ->

		# Update existing shadows.
		for s in @shadows
			s.alpha -= 0.05

		# Delete expired shadows
		shadows = []
		for s in @shadows
			if s.alpha > 0.01
				shadows.push s
		@shadows = shadows

		# Add a new shadow if the effect is still running.
		if @running and @updates % @density is 0
				@shadows.push
					x: @object.pos.x
					y: @object.pos.y
					dir: @object.dir
					alpha: 0.6

		++@updates

	deletable: () ->
		not @running and @shadows.length is 0

	inView: (offset = {x:0, y:0}) ->
		true

	draw: (ctxt, offset = {x:0, y:0}) ->
		for s in @shadows
			ctxt.save()
			ctxt.translate(s.x, s.y)
			ctxt.rotate(s.dir)
			@object.drawModel(ctxt, color(@object.color, s.alpha))
			ctxt.restore()

# Exports
window.BoostEffect = BoostEffect
