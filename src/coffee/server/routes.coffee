#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

constants  = require '../constants'
express    = require 'express'
{Composer} = require './server_schema'
w          = require 'when'

############################################################################################################

module.exports = router = express.Router()

# Root-Level Routes ####################################################################

router.get '/', (request, response)->
    response.redirect '/composers'

# Composer Routes ######################################################################

router.get '/api/composers', (request, response)->
    offset = parseInt(request.query.offset) or 0
    limit = parseInt(request.query.limit) or constants.PAGE_SIZE

    response.sendPromise ->
        Composer.findAll orderBy: ['last_name', 'first_name'], offset:offset, limit:limit
            .then (composers)->
                return (c.toJSON() for c in composers)

router.get '/api/composers/count', (request, response)->
    response.sendPromise ->
        Composer.count()

router.get '/api/composers/:id', (request, response)->
    response.sendPromise ->
        Composer.find request.params.id
            .then (composer)->
                return composer.toJSON()

router.get '/composers/:id', (request, response)->
    response.sendFile './composers/show.html', root:constants.STATIC_BASE
