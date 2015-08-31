#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

_ = require 'underscore'

############################################################################################################

module.exports =

    name:     'composer'
    endpoint: '/api/composers'
    table:    'composers'
    methods:

        getDetailUrl: ->
            return "/composers/#{@id}"

        toJSON: ->
            return _.pick this, 'id', 'first_name', 'last_name', 'url'
