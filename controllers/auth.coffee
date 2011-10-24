bcrypt = require 'bcrypt'
_ = require 'underscore'
mongoose = require 'mongoose'

config = require '../config'

mongoose.connect "mongodb://#{config.db.host}/#{config.db.db}"

UserModel = require '../models/user'

module.exports = (app) ->

	# register
	app.get '/register', (req, res) ->
		res.render 'register'
	
	app.post '/register', (req, res) ->
		console.log req.body

		user = _.extend new UserModel, req.body

		bcrypt.gen_salt 10, (err, salt) ->
			bcrypt.encrypt req.body.password, salt, (err, hash) ->
				user.hash = hash
				user.save()
		
		req.flash 'success', "Registration Successful"
		res.redirect '/login'
	
	# login
	app.get '/login', (req, res) ->
		res.render 'login'
	
	app.post '/login', (req, res) ->
		invalid = () ->
			req.flash 'error', 'Invalid Username / Password Combination'
			res.render 'login', locals: req.body

		if req.body.email and req.body.password
			UserModel.findOne email: req.body.email, (err, doc) ->
				if doc
					console.log 'user found'
					bcrypt.compare req.body.password, doc.hash, (err, matched) ->
						if matched
							req.session.loggedIn = yes
							res.redirect '/admin'
						else
							invalid()
				else
					console.log 'invalid user'
					invalid()
		else
			invalid()
		
	
	# forgot password
	app.get '/login/forgot', (req, res) ->
		req.flash 'info', "Module Routes Work!"
		res.redirect '/'
	
	# logout
	app.get '/logout', (req, res) ->
		req.session.loggedIn = no
		req.flash 'info', "You've been signed out."
		res.redirect '/'

	## admin routes

	# admin auth check
	app.all '/admin*?', (req, res, next) ->
		unless req.session.loggedIn
			req.flash 'warning', "You're not signed in."
			res.redirect '/login'
		else
			next()
	
	# admin signout
	app.get '/admin/signout', (req, res) ->
		res.redirect '/logout'

	# account
	app.get '/admin/account', (req, res) ->
		req.flash 'info', "Module Routes Work!"
		res.redirect '/'
	
	# edit account
	app.get '/admin/account/edit', (req, res) ->
		req.flash 'info', "Module Routes Work!"
		res.redirect '/'
	
	# delete account
	app.get '/admin/account/delete', (req, res) ->
		req.flash 'info', "Module Routes Work!"
		res.redirect '/'
	
	# create account
	app.get '/admin/account/create', (req, res) ->
		req.flash 'info', "Module Routes Work!"
		res.redirect '/'