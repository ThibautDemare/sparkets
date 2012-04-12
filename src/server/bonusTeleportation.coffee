Teleportation = require('./teleportation').Teleportation

class BonusTeleportation
	type: 'teleportation'

	constructor: (@game, @bonus) ->
		@teleportation = true
				
	use: () ->
		#Define the target pos the fisrt time, and the second time, create a teleportation object
		if @teleportation
			@target =
				x: @bonus.holder.pos.x
				y: @bonus.holder.pos.y
			@teleportation = false
		else
			@game.newGameObject (id) =>
				dropPos = {x: @bonus.pos.x, y: @bonus.pos.y}
				new Teleportation(id, @game, @bonus.holder, dropPos, @target)
			@bonus.holder.releaseBonus()
			@bonus.setState 'dead'
		
exports.BonusTeleportation = BonusTeleportation
exports.constructor = BonusTeleportation
exports.type = 'bonusTeleportation'
