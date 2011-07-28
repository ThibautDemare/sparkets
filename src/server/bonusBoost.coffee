class BonusBoost
	type: 'boost'

	constructor: (@game, @bonus) ->

	use: () ->
		ship = @bonus.holder

		# Boost da ship.
		ship.boost = @game.prefs.bonus.boost.boostFactor
		ship.boostDecay = 0

		ship.flagNextUpdate('boost')

		# Send event to client.
		@game.events.push
			type: 'ship boosted'
			id: ship.id

		# DELETEME
		@used = yes

		# Cancel the previous pending boost decay.
		if ship.bonusTimeout.bonusBoost?
			clearTimeout(ship.bonusTimeout.bonusBoost)

		# Setup decay for this boost.
		ship.bonusTimeout[exports.type] = setTimeout(( () =>
			@game.gameObjects[ship.id].boostDecay = @game.prefs.bonus.boost.boostDecay ),
			@game.prefs.bonus.boost.boostDuration)

		# Clean up.
		ship.releaseBonus()
		@bonus.setState 'dead'

exports.BonusBoost = BonusBoost
exports.constructor = BonusBoost
exports.type = 'bonusBoost'
