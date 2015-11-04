#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

_ = require '../underscore'

############################################################################################################

PUBLIC_FIELDS = [
    'id', 'first_name', 'last_name', 'url'
]

############################################################################################################

module.exports =

    name:     'composer'
    endpoint: '/api/composers'
    table:    'composers'

    computed:

        full_name: ['first_name', 'last_name', (first_name, last_name)->
            return "#{first_name} #{last_name}"
        ]

    methods:

        getDetailUrl: ->
            return "/composers/#{@id}"

        toJSON: ->
            return _.pick this, PUBLIC_FIELDS

        toView: ->
            view = @toJSON()
            view.full_name = @full_name
            view.detail_url = @getDetailUrl()
            return view
