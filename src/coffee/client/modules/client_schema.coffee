#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular = require 'angular'

############################################################################################################

schema = angular.module 'schema', ['js-data']

schema.run (DS)->
    adapter = DS.getAdapter 'http'

    # Adds a "count" method to each Resource instance
    DS.defaults.count = (params)->
        adapter.GET "#{@endpoint}/count", params:params
            .then (response)->
                return parseInt response.data

schema.factory 'Composer', (DS)-> DS.defineResource require '../../model/composers'
schema.factory 'Work',     (DS)-> DS.defineResource require '../../model/works'
