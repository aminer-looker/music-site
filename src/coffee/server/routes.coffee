#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

constants  = require '../constants'
express    = require 'express'
{Composer} = require './server_schema'

############################################################################################################

module.exports = router = express.Router()

# Composer Routes ######################################################################

router.get '/composers', (request, response)->
    Composer.findAll().then (composers)-> response.send composers
