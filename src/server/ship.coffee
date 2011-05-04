ChangingObject = require './changingObject'
globals = require './server'
utils = require '../utils'
Bullet = require './bullet'

class Ship extends ChangingObject.ChangingObject
	constructor: (@id) ->
		super()

		@color = utils.randomColor()
		@spawn()

	spawn: () ->
		@watchChanges 'pos'
		@watchChanges 'vel'
		@watchChanges 'dir'
		@watchChanges 'firePower'
		@watchChanges 'cannonHeat'
		@watchChanges 'dead'
		@watchChanges 'exploding'
		@watchChanges 'exploFrame'

		@pos =
			x: Math.random() * globals.map.w
			y: Math.random() * globals.map.h
		@vel =
			x: 0
			y: 0
		@dir = Math.random() * 2*Math.PI
		@firePower = globals.minFirepower
		@cannonHeat = 0
		@dead = false
		@exploFrame = 0

		@spawn() if @collidesWithPlanet()

	move: () ->
		x = @pos.x
		y = @pos.y

		@pos.x += @vel.x
		@pos.y += @vel.y

		# Warp the ship around the map
		@pos.x = if @pos.x < 0 then globals.map.w else @pos.x
		@pos.x = if @pos.x > globals.map.w then 0 else @pos.x
		@pos.y = if @pos.y < 0 then globals.map.h else @pos.y
		@pos.y = if @pos.y > globals.map.h then 0 else @pos.y

		@vel.x *= globals.frictionDecay
		@vel.y *= globals.frictionDecay

		if Math.abs(@pos.x-x) > .05 or
				Math.abs(@pos.y-y) > .05
			@changed 'pos'
			@changed 'vel'

	collides: () ->
		@collidesWithOtherShip() or
			@collidesWithBullet() or
			@collidesWithPlanet()

	collidesWithOtherShip: () ->
		for id, ship of globals.ships
			if @id isnt ship.id and
					not ship.isDead() and
					not ship.isExploding() and
					-10 < @pos.x - ship.pos.x < 10 and
					-10 < @pos.y - ship.pos.y < 10
				ship.explode()
				return true

		return false

	collidesWithPlanet: () ->
		x = @pos.x
		y = @pos.y

		for p in globals.planets
			px = p.pos.x
			py = p.pos.y
			return true if utils.distance(px, py, x, y) < p.force

		return false

	collidesWithBullet: () ->
		x = @pos.x
		y = @pos.y

		for b in globals.bullets
			if not b.dead and
					-10 < x - b.pos.x < 10 and
					-10 < y - b.pos.y < 10
				b.dead = true
				return true

		return false

	isExploding: () ->
		@exploding

	isDead: () ->
		@dead

	update: () ->
		return if @isDead()

		if @isExploding()
			@updateExplosion()
		else
			--@cannonHeat if @cannonHeat > 0
			@move()
			@explode() if @collides()

	fire : () ->
		return if @isDead() or @isExploding() or @cannonHeat > 0

		globals.bullets.push( new Bullet.Bullet( @, globals.bulletCount++ ))
		globals.bullets.shift() if globals.bullets.length > globals.maxBullets

		@firePower = globals.minFirepower
		@cannonHeat = globals.cannonCooldown

	explode : () ->
		@exploding = true
		@exploFrame = 0

	updateExplosion : () ->
		++@exploFrame

		if @exploFrame > globals.maxExploFrame
			@exploding = false
			@dead = true
			@exploFrame = 0

exports.Ship = Ship