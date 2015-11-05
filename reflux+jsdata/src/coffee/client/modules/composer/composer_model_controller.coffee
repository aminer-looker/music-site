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
        return unless event is EVENT.CHANGE
        $scope.$apply ->
            $scope.composer = ComposerModelStore.get()

    readLocationForId = ->
        match = /.*\/(.*)$/.exec $location.path()
        return null unless match?

        id = parseInt match[1]
        return null unless _.isNumber id

        return id

    ComposerActions.load readLocationForId()
