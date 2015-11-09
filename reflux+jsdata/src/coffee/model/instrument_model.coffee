#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

ReadOnlyView = require '../read_only_view'
_ = require '../underscore'

############################################################################################################

PUBLIC_FIELDS = [ 'id', 'name' ]

############################################################################################################

module.exports =
    name:     'instrument'
    endpoint: '/api/instruments'
    table:    'instruments'

    methods:

        toJSON: ->
            return _.pick this, 'id', 'name'

        toReadOnlyView: ->
            return new ReadOnlyView this, PUBLIC_FIELDS
