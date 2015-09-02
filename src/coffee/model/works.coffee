#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

_ = require '../underscore'

############################################################################################################

module.exports =
    name:     'work'
    endpoint: '/api/works'
    table:    'works'

    methods:

        getDetailUrl: ->
            return "/works/#{@id}"

        toJSON: ->
            return _.pick this,
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