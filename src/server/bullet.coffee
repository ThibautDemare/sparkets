ChangingObject = require('./changingObject').ChangingObject

class Bullet extends ChangingObject
	constructor: (@id, @game, @owner) ->
		super()

		# Send these properties to new players.
		@flagFullUpdate('type')
		@flagFullUpdate('ownerId')
		@flagFullUpdate('lastPoints')
		@flagFullUpdate('serverDelete')
		@flagFullUpdate('boundingRadius')
		@flagFullUpdate('hitBox') if @game.prefs.debug.sendHitBoxes

		@type = 'bullet'
		@flagNextUpdate('type')

		# Transmit owner id to clients.
		@ownerId = @owner.id
		@flagNextUpdate('ownerId')

		# Compute initial position and velocity vector from position
		# and direction of owner ship.
		xdir = 10*Math.cos(@owner.dir)
		ydir = 10*Math.sin(@owner.dir)
		@power = @owner.firePower
		@pos =
			x: @owner.pos.x + xdir
			y: @owner.pos.y + ydir
		@vel =
			x: @owner.vel.x + @power*xdir
			y: @owner.vel.y + @power*ydir

		# Keep track of the last computed position to notify clients.
		@lastPoints = [ [@pos.x, @pos.y] ]

		@flagNextUpdate('lastPoints')

		# Initial hit box is a point.
		@boundingRadius = @game.prefs.bullet.boundingRadius
		@hitBox =
			type: 'segments'
			points: [
				{x: @pos.x, y: @pos.y},
				{x: @pos.x, y: @pos.y}]

		@state = 'active'

	# Apply gravity from all planets, moons, and shields.
	gravityVector: () ->
		# Get planets, moons and shields.
		filter = (obj) ->
			obj.type is 'planet' or obj.type is 'moon' or obj.type is 'shield'

		# Pull factor for each object.
		force = ({object: obj}) =>
			if obj.type is 'shield'
				if obj.owner is @owner
					0
				else
					@game.prefs.bullet.shieldPull * obj.force
			else
				@game.prefs.bullet.gravityPull * obj.force

		return @game.gravityFieldAround(@pos, filter, force)

	unflagAllNextUpdate: () ->
		super()

		# Only reset last points when the update has finished.
		@lastPoints = []

	move: (step) ->
		return if @state isnt 'active'

		# Keep the starting position for hit box update.
		prevPos = {x: @pos.x, y: @pos.y}

		# Compute new position from velocity and gravity of all planets.
		gvec = @gravityVector()

		@vel.x += gvec.x
		@vel.y += gvec.y

		@pos.x += @vel.x
		@pos.y += @vel.y

		# Register new position for clients.
		@lastPoints.push [@pos.x, @pos.y]

		@flagNextUpdate('lastPoints')

		# Warp the bullet around the map.
		s = @game.prefs.mapSize
		warping = {x: 0, y: 0}
		if @pos.x < 0
			warping.x = s
		else if @pos.x > s
			warping.x = -s
		if @pos.y < 0
			warping.y = s
		else if @pos.y > s
			warping.y = -s

		if warping.x isnt 0 or warping.y isnt 0
			@pos.x += warping.x
			@pos.y += warping.y

			# Append the warped point again so that the line remains continuous.
			@lastPoints.push [@pos.x, @pos.y]

		# Update hitbox. Since collisions are relative to the bounding
		# box position (currently @pos), we need to wrap both points of
		# the hit segment.
		@hitBox.points[0].x = prevPos.x + warping.x
		@hitBox.points[0].y = prevPos.y + warping.y
		@hitBox.points[1].x = @pos.x
		@hitBox.points[1].y = @pos.y

		@flagNextUpdate('hitBox.points') if @game.prefs.debug.sendHitBoxes

	update: (step) ->
		if @state is 'dead'
			@serverDelete = yes

			@flagNextUpdate('serverDelete')

	explode: () ->
		@state = 'dead'

	tangible: ->
		@state is 'active'

exports.Bullet = Bullet
