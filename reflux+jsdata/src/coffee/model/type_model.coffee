#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

ReadOnlyView = require '../read_only_view'
_ = require '../underscore'

############################################################################################################

PUBLIC_FIELDS = ['id', 'name']

############################################################################################################

module.exports =
    name:     'type'
    endpoint: '/api/types'
    table:    'types'

    methods:

        toJSON: ->
            return _.pick this, 'id', 'name'

        toReadOnlyView: ->
            return new ReadOnlyView this, @public_fields
