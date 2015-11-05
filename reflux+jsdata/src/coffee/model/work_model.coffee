#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

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

module.exports =
    name:     'work'
    endpoint: '/api/works'
    table:    'works'

    computed:
        detail_url: -> "/works/#{@id}"
        public_fields: -> PUBLIC_FIELDS

    methods:

        mergeView: (view)->
            for field in PUBLIC_FIELDS
                this[field] = view[field]
                this[field] = null unless this[field] # convert falsy values to null

        toJSON: ->
            return _.pick this, PUBLIC_FIELDS

        toView: (options={})->
            options.relations ?= []

            view = @toJSON()
            view.detail_url = @detail_url

            if 'composer' in options.relations and @composer?
                view.composer = @composer.toView()

            if 'instrument' in options.relations and @instrument?
                view.instrument = @instrument.toView()

            if 'type' in options.relations and @type?
                view.type = @type.toView()

            return view

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