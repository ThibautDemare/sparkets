ChangingObject = require('./changingObject').ChangingObject
stateMachineMixin = require('./stateMachine').mixin
utils = require '../utils'

class Teleportation extends ChangingObject

	stateMachineMixin.call(@prototype)

	constructor: (@id, @game, @owner, @pos) ->
		super()

		# Send these properties to new players.
		@flagFullUpdate('type')
		@flagFullUpdate('ownerId')
		@flagFullUpdate('pos')
		@flagFullUpdate('state')
		@flagFullUpdate('radius')
		@flagFullUpdate('serverDelete')
		if @game.prefs.debug.sendHitBoxes
			@flagFullUpdate('boundingBox')
			@flagFullUpdate('hitBox')

		@type = 'teleportation'
		@flagNextUpdate('type')

		# Transmit owner id to clients.
		@ownerId = @owner.id
		@flagNextUpdate('ownerId')

		# Initial state.
		@setState 'inactive'

		# Static position.
		@pos =
			x: pos.x
			y: pos.y
		@flagNextUpdate('pos')

		# Target position.
		@target =
			targetX: Math.random() * @game.prefs.mapSize
			targetY: Math.random() * @game.prefs.mapSize

		# Find a safe target location.
		while @collideWithPlanet()
			@target.targetX = Math.random() * @game.prefs.mapSize
			@target.targetY = Math.random() * @game.prefs.mapSize

		@flagNextUpdate('target')
		
		# Hit box is a circle with static position and varying radius.
		@radius = 0
		@flagNextUpdate('radius')

		@boundingBox =
			x: @pos.x
			y: @pos.y
			radius: @radius

		@hitBox =
			type: 'circle'
			x: @pos.x
			y: @pos.y
			radius: @radius

		if @game.prefs.debug.sendHitBoxes
			@flagNextUpdate('boundingBox')
			@flagNextUpdate('hitBox')
	
	collideWithPlanet: () ->
		collidesWith = (p) ->
			if p.type is 'moon'
				x2 = p.planet.pos.x
				y2 = p.planet.pos.y
				r2 = p.dist + p.force
			else
				x2 = p.pos.x
				y2 = p.pos.y
				r2 = p.force
			return (utils.distance(x, y, x2, y2) < r + r2)

		x = @target.targetX
		y = @target.targetY
		r = @game.prefs.shield.planetAffectDistance

		for id, planet of @planets
			return true if collidesWith(planet)
		return false

	tangible: () ->
		@state is 'active' or @state is 'disapear'

	move: (step) ->

		switch @state

			# The teleportation is active.
			when 'active'
				# FIXME: slower in powersave mode.
				@radius += @game.prefs.mine.waveSpeed
				if @radius >= @game.prefs.mine.maxDetectionRadius
					@radius = @game.prefs.mine.minDetectionRadius
				@flagNextUpdate('radius')

		# Update hit box radius.
		@boundingBox.radius = @hitBox.radius = @radius
		if @game.prefs.debug.sendHitBoxes
			@flagNextUpdate('boundingBox.radius')
			@flagNextUpdate('hitBox.radius')

	update: (step) ->

		@updateState(step)

		switch @state
			# The teleportation is over.
			when 'disapear'
				@serverDelete = yes
				@flagNextUpdate('serverDelete')

	explode: () ->
		@setState 'exploding'

		@game.events.push
			type: 'teleportation exploded'
			id: @id

exports.Teleportation = Teleportation
