#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

constants  = require '../constants'
express    = require 'express'
w          = require 'when'
{Composer} = require './server_schema'
{Work}     = require './server_schema'

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

# Work Routes ##########################################################################

router.get '/api/works', (request, response)->
    offset = parseInt(request.query.offset) or 0
    limit = parseInt(request.query.limit) or constants.PAGE_SIZE
    composer_id = parseInt(request.query.composer_id)

    options = orderBy: ['title'], offset:offset, limit:limit
    options.composer_id = composer_id if composer_id?

    response.sendPromise ->
        Work.findAll options
            .then (works)->
                return (c.toJSON() for c in works)

router.get '/api/works/count', (request, response)->
    response.sendPromise ->
        Work.count (query)->
            composer_id = request.query.composer_id
            if composer_id? then query.where composer_id:composer_id

router.get '/api/works/:id', (request, response)->
    response.sendPromise ->
        Work.find request.params.id
            .then (work)->
                return work.toJSON()

router.get '/works/:id', (request, response)->
    response.sendFile './works/show.html', root:constants.STATIC_BASE
