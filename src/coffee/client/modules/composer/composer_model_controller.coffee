#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular = require 'angular'
_       = require 'underscore'

############################################################################################################

angular.module('composer').controller 'ComposerModelController', (
    $location, $scope, $timeout, ComposerActions, ComposerModelStore
)->
    ComposerModelStore.$listen $scope, (event, id)->
        $scope.composer = ComposerModelStore.get()

    readLocationForId = ->
        match = /.*\/(.*)$/.exec $location.path()
        return null unless match?

        id = parseInt match[1]
        return null unless _.isNumber id

        return id

    ComposerActions.load readLocationForId()
