#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular = require 'angular'
_       = require '../../underscore'

############################################################################################################

urlModule = angular.module 'url', []

urlModule.factory 'UrlUtils', ($location)->

    findId: ->
        match = /.*\/(.*)$/.exec $location.path()
        return null unless match?

        id = parseInt match[1]
        return null unless _.isNumber id

        return id
