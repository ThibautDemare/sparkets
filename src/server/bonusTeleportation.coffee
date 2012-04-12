Teleportation = require('./teleportation').Teleportation

class BonusTeleportation
	type: 'teleportation'

	constructor: (@game, @bonus) ->
		@teleportation = @game.prefs.bonus.teleportation.teleportationCount
		@target =
			x: 0#@bonus.holder.pos.x
			y: 0#@bonus.holder.pos.y
				
	use: () ->
		return if @teleportation < 0
		
		# Clean up if there is no more mine.
		if @teleportation > 0
			@target =
				x: @bonus.holder.pos.x
				y: @bonus.holder.pos.y
			console.log('avant : target : x='+@target.x+' y='+@target.y)
		else
			@game.newGameObject (id) =>
				dropPos = {x: @bonus.pos.x, y: @bonus.pos.y}
				@game.teleportations[id] = new Teleportation(id, @game, @bonus.holder, dropPos, @target)
			@bonus.holder.releaseBonus()
			@bonus.setState 'dead'
			
		# Decrease teleportation count.
		--@teleportation
		
exports.BonusTeleportation = BonusTeleportation
exports.constructor = BonusTeleportation
exports.type = 'bonusTeleportation'
