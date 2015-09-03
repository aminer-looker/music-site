#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

_ = require '../underscore'

############################################################################################################

module.exports =
    name:     'type'
    endpoint: '/api/types'
    table:    'types'

    methods:

        toJSON: ->
            return _.pick this, 'id', 'name'