#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

_ = require 'underscore'

############################################################################################################

module.exports =

    name:     'composer'
    endpoint: '/composers'
    table:    'composers'
    methods:

        toJSON: ->
            return _.pick this, 'id', 'first_name', 'last_name'
