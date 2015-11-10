#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

ReadOnlyView = require '../read_only_view'
_            = require '../underscore'

############################################################################################################

PUBLIC_FIELDS = ['id', 'first_name', 'last_name', 'url']

############################################################################################################

module.exports =

    name:     'composer'
    endpoint: '/api/composers'
    table:    'composers'

    computed:

        detail_url: ['id', (id)->
            return "/composers/#{id}"
        ]

        full_name: ['first_name', 'last_name', (first_name, last_name)->
            return "#{first_name} #{last_name}"
        ]

    methods:

        toJSON: ->
            return _.pick this, PUBLIC_FIELDS

        toReadOnlyView: ->
            return new ReadOnlyView this, PUBLIC_FIELDS, 'detail_url', 'full_name'
