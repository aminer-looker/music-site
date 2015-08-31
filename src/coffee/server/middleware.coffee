#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

bodyParser     = require 'body-parser'
constants      = require '../constants'
clientSessions = require 'client-sessions'
express        = require 'express'
w              = require 'when'

############################################################################################################

exports.installBefore = (app)->
    app.use m for m in [
        bodyParser.json
            limit:      '1024kb'
        clientSessions
            cookieName: 'music-site-session'
            duration:   1000 * 60 * 60 * 24 * 7 * 2 # 2 weeks in ms
            secret:     '2liLtyVp3jIyPIOq'
        promisify
    ]

exports.installAfter = (app)->
    app.use m for m in [
        express.static './static'
    ]

# Middleware Functions #####################################################################################

promisify = (request, response, next)->
    response.sendPromise = (func)->
        w.try func
            .then (result)->
                responseText = JSON.stringify result
                console.log "sending response:\n#{responseText}"
                response.send responseText
            .catch (error)->
                console.error "Request failed with error:\n#{error.stack}"
                response.status 500
                response.send message:error.message, stack:error.stack
            .done()
    next()
