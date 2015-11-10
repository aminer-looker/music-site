#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

ReadOnlyView = require '../read_only_view'
_ = require '../underscore'

############################################################################################################

PUBLIC_FIELDS = [
    'id'
    'title'
    'catalog_name'
    'opus'
    'opus_num'
    'composed_year'
    'difficulty'
    'key_area'
    'url'
    'composer_id'
    'type_id'
    'instrument_id'
    'collection_id'
]

############################################################################################################

module.exports =
    name:     'work'
    endpoint: '/api/works'
    table:    'works'

    computed:

        detail_url: ['id', (id)->
            return "/works/#{id}"
        ]

    methods:

        mergeChanges: (changes)->
            for field in PUBLIC_FIELDS
                this[field] = changes[field]
                this[field] = null unless this[field] # convert falsy values to null

        toJSON: ->
            return _.pick this, PUBLIC_FIELDS

        toReadOnlyView: ->
            return new ReadOnlyView this, PUBLIC_FIELDS, 'composer', 'detail_url', 'instrument', 'type'

    relations:

        belongsTo:
            composer:
                localField: 'composer'
                localKey:   'composer_id'
                foreignKey: 'id'

        hasOne:
            instrument:
                localField: 'instrument'
                localKey:   'instrument_id'
                foreignKey: 'id'

            type:
                localField: 'type'
                localKey:   'type_id'
                foreignKey: 'id'
