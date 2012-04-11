Teleportation = require('./teleportation').Teleportation

class BonusTeleportation
	type: 'teleportation'

	constructor: (@game, @bonus) ->
		@teleportation = @game.prefs.bonus.teleportation.teleportationCount

	use: () ->
		return if @teleporation <= 0

		@game.newGameObject (id) =>
			dropPos = {x: @bonus.pos.x, y: @bonus.pos.y}
			@game.teleportations[id] = new Teleportation(id, @game, @bonus.holder, dropPos)

		# Decrease mine count.
		--@teleporation

		# Clean up if there is no more mine.
		#if @teleporation is 0
		@bonus.holder.releaseBonus()
		@bonus.setState 'dead'

exports.BonusTeleportation = BonusTeleportation
exports.constructor = BonusTeleportation
exports.type = 'bonusTeleportation'
