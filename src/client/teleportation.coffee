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

		# Draw the animation when the teleportation is active.
		if @state is 'active'
			for r in [@externRadius...@internRadius] by -1
				ctxt.save()
				ctxt.lineWidth = 2
				ctxt.strokeStyle = utils.color(@color, 1-(r)/@externRadius)
				ctxt.translate(@pos.x, @pos.y)
				ctxt.scale(0.75, 1);#in order to draw an ellipse with the arc function
				ctxt.beginPath()
				ctxt.arc(0, 0, r, 0, 2*Math.PI, false)
				ctxt.stroke()
				ctxt.restore()
				

	inView: (offset = {x:0, y:0}) ->
		@client.boxInView(@pos.x + offset.x, @pos.y + offset.y, @externRadius)

# Exports
window.Teleportation = Teleportation
