#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

constants  = require '../constants'
express    = require 'express'
util       = require 'util'
{Composer} = require './server_schema'

############################################################################################################

module.exports = router = express.Router()

# Composer Routes ######################################################################

router.get '/composers', (request, response)->
    response.sendPromise ->
        Composer.findAll(orderBy: 'last_name').then (composers)->
            return (c.toJSON() for c in composers)
