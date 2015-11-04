#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular              = require 'angular'
_                    = require 'underscore'
{ERROR_DISPLAY_TIME} = require '../../../constants'
{EVENT}              = require '../../../constants'

############################################################################################################

angular.module('composer').controller 'ComposerModelController', (
    $location, $scope, $timeout, ComposerActions, ComposerModelStore
)->
    ComposerModelStore.listen (event, id)->
        $scope.$apply ->
            if event is EVENT.CHANGE
                $scope.composer = ComposerModelStore.get()
            else if event is EVENT.ERROR
                $scope.error = ComposerModelStore.getError()
                $timeout (-> $scope.error = null), ERROR_DISPLAY_TIME

    readLocationForId = ->
        match = /.*\/(.*)$/.exec $location.path()
        return null unless match?

        id = parseInt match[1]
        return null unless _.isNumber id

        return id

    ComposerActions.load readLocationForId()
