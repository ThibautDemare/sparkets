class Teleportation
	constructor: (@client, teleportation) ->
		@serverUpdate(teleportation)

		@color = @client.gameObjects[@ownerId].color

		# Create the sprite.
		s = 10*Math.sqrt(2) # The size of the sprite equals the diagonal of the squares forming the sprite.
		color = window.utils.color @color
		@sprite = @client.spriteManager.get('teleportation', s, s, color)

	serverUpdate: (teleportation) ->
		utils.deepMerge(teleportation, @)

	update: () ->
		@clientDelete = @serverDelete

	drawHitbox: (ctxt) ->
		return if not @hitBox?

		ctxt.strokeStyle = 'red'
		ctxt.lineWidth = 1.1
		utils.strokeCircle(ctxt, @hitBox.x, @hitBox.y, @hitBox.radius)

	draw: (ctxt) ->
		return if @state is 'exploding' or @state is 'dead'

		# Draw the body of the teleportation.
		ctxt.save()
		ctxt.translate(@pos.x, @pos.y)
		ctxt.drawImage(@sprite, -@sprite.width/2, -@sprite.height/2)
		ctxt.restore()

		# Draw the sensor wave when the teleportation is active.
		if @state is 'active'
			for r in [@radius...0] by -20
				ctxt.save()
				ctxt.lineWidth = 3
				ctxt.strokeStyle = utils.color(@color, 1-r/50)
				ctxt.translate(@pos.x, @pos.y)
				ctxt.beginPath()
				ctxt.arc(0, 0, r, 0, 2*Math.PI, false)
				ctxt.stroke()
				ctxt.restore()

	inView: (offset = {x:0, y:0}) ->
		@client.boxInView(@pos.x + offset.x, @pos.y + offset.y, @radius)

	teleportationEffect: () ->
		#@client.effects.push new TeleportationEffect(@client, @pos, 80, @color, 500)

# Exports
window.Teleportation = Teleportation
