ChangingObject = require('./changingObject').ChangingObject
stateMachineMixin = require('./stateMachine').mixin
utils = require '../utils'

class Teleportation extends ChangingObject

	stateMachineMixin.call(@prototype)

	constructor: (@id, @game, @owner, @pos, @target) ->
		super()

		# Send these properties to new players.
		@flagFullUpdate('type')
		@flagFullUpdate('ownerId')
		@flagFullUpdate('pos')
		@flagFullUpdate('state')
		@flagFullUpdate('externRadius')
		@flagFullUpdate('internRadius')
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
			x: target.x
			y: target.y

		@flagNextUpdate('target')
		
		# Hit box is a circle with static position and varying radius.
		@externRadius = 20
		@flagNextUpdate('externRadius')

		@internRadius = 10
		@flagNextUpdate('internRadius')
		
		@boundingBox =
			x: @pos.x
			y: @pos.y
			radius: @externRadius

		@hitBox =
			type: 'circle'
			x: @pos.x
			y: @pos.y
			radius: @externRadius

		if @game.prefs.debug.sendHitBoxes
			@flagNextUpdate('boundingBox')
			@flagNextUpdate('hitBox')
	
	tangible: () ->
		@state is 'active' or @state is 'disappear'

	move: (step) ->

		switch @state
			# The teleportation is active.
			when 'active'
				# FIXME: slower in powersave mode.
				if @externRadius < @game.prefs.teleportation.maxDetectionRadius
					@externRadius += @game.prefs.teleportation.waveSpeed
				else
					@externRadius = @game.prefs.teleportation.maxDetectionRadius
				@flagNextUpdate('externRadius')
				
				@internRadius -= @game.prefs.teleportation.waveSpeed
				if @internRadius < @game.prefs.teleportation.minDetectionRadius
					@internRadius = @externRadius
				@flagNextUpdate('internRadius')
				
		# Update hit box radius.
		@boundingBox.radius = @hitBox.radius = @externRadius
		if @game.prefs.debug.sendHitBoxes
			@flagNextUpdate('boundingBox.radius')
			@flagNextUpdate('hitBox.radius')

	update: (step) ->

		@updateState(step)

		switch @state
			# The teleportation is over.
			when 'disappear'
				@serverDelete = yes
				@flagNextUpdate('serverDelete')

	explode: () ->
		@setState 'exploding'

		@game.events.push
			type: 'teleportation exploded'
			id: @id

exports.Teleportation = Teleportation
