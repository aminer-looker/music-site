#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

constants  = require '../constants'
express    = require 'express'
{Composer} = require './server_schema'

############################################################################################################

module.exports = router = express.Router()

# Root-Level Routes ####################################################################

router.get '/', (request, response)->
    response.redirect '/composers'

# Composer Routes ######################################################################

router.get '/api/composers', (request, response)->
    response.sendPromise ->
        Composer.findAll orderBy: ['last_name', 'first_name']
            .then (composers)->
                return (c.toJSON() for c in composers)

router.get '/api/composers/:id', (request, response)->
    response.sendPromise ->
        Composer.find request.params.id
            .then (composer)->
                return composer.toJSON()

router.get '/composers/:id', (request, response)->
    response.sendFile './composers/show.html', root:constants.STATIC_BASE
