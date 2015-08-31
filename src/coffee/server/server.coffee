#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

w = require 'when'
global.Promise = w.promise # must be before JS-Data loads

_          = require 'underscore'
express    = require 'express'
http       = require 'http'
SqlAdapter = require 'js-data-sql'
middleware = require './middleware'
routes     = require './routes'
schema     = require './server_schema'

############################################################################################################

module.exports = class Server

    constructor: (port)->
        if not port? then throw new Error 'port is mandatory'
        if not _.isNumber port then throw new Error 'port must be a number'
        @port = parseInt port

        @expressApp = @_configureRouter()
        @httpServer = @_configureServer @expressApp
        @store      = @_configureStore()

    start: ->
        w.promise (resolve, reject)=>
            @httpServer.once 'error', (error)-> reject error
            @httpServer.listen @port, =>
                console.log "Classical Music DB Site is listening on port #{@port}\n\n"
                resolve this

    stop: ->
        w.promise (resolve, reject)=>
            console.log "Classical Music DB Site is shutting down"
            @httpServer.close() =>
                resolve this

    # Private Methods ##################################################################

    _configureRouter: ->
        app = express()

        app.use m for m in middleware.before
        app.use routes
        app.use m for m in middleware.after

        return app

    _configureServer: (app)->
        if not app? then throw new Error 'app is required'
        return http.createServer app

    _configureStore: ->
        adapter = new SqlAdapter
            client: 'mysql'
            connection:
                host: 'localhost'
                user: 'root'

        schema.store.registerAdapter 'sql', adapter, default:true
        return schema.store

############################################################################################################

if require.main is module
    port = parseInt process.argv[2]
    port = if _.isNaN port then 8080 else port

    server = new Server port
    server.start()

    process.on 'SIGINT', ->
        server.stop().finally ->
            process.exit()
