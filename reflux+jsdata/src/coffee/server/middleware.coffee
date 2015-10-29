#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

_              = require 'underscore'
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
        logRequest
        prevent304
        promisify
    ]

exports.installAfter = (app)->
    app.use m for m in [
        express.static('./static'
            etag: false
            maxAge: 0
        )
    ]

# Middleware Functions #####################################################################################

logRequest = (request, response, next)->
    console.log ">>>>> #{request.method} #{request.url}"

    receivedAt = Date.now()
    totalBytes = 0

    originalWrite = response.write
    response.write = (chunk)->
        totalBytes += chunk.length if chunk?.length?
        originalWrite.apply response, arguments

    originalEnd = response.end
    response.end = (chunk)->
        totalBytes += chunk.length if chunk?.length?

        duration = Date.now() - receivedAt
        sizeText = if totalBytes > 1024 then "#{(totalBytes / 1024.0).toFixed(2)} kB" else "#{totalBytes} B"
        console.log "<<<<< #{request.method} #{request.url} responded " +
            "#{response.statusCode} after #{duration}ms with #{sizeText}\n"
        originalEnd.apply response, arguments

    next()

prevent304 = (request, response, next)->
    response.setHeader 'Last-Modified', new Date().toUTCString()
    next()

promisify = (request, response, next)->
    response.sendPromise = (func)->
        w.try func
            .then (result)->
                responseText = JSON.stringify result
                console.log "#{responseText}"
                response.send responseText
            .catch (error)->
                if error.status?
                    response.status error.status
                else
                    console.error "Request failed with error:\n#{error.stack}"
                    response.status 500

                response.send _.pick error, 'message', 'data', 'stack'
            .done()
    next()
