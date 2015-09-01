#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular = require 'angular'

############################################################################################################

module.exports = schema = angular.module 'schema', ['js-data']

schema.run (DS)->
    adapter = DS.getAdapter 'http'

    # Adds a "count" method to each Resource instance
    DS.defaults.count = ->
        adapter.GET "#{@endpoint}/count"
            .then (response)->
                return parseInt response.data

schema.factory 'Composer', (DS)->
    return DS.defineResource require '../model/composers'
