#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

_ = require '../underscore'

############################################################################################################

module.exports =
    name:     'instrument'
    endpoint: '/api/instruments'
    table:    'instruments'

    methods:

        toJSON: ->
            return _.pick this, 'id', 'name'
