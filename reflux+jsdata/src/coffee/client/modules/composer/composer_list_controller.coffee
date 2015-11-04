#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular              = require 'angular'
{ERROR_DISPLAY_TIME} = require '../../../constants'
{EVENT}              = require '../../../constants'

############################################################################################################

angular.module('composer').controller 'ComposerListController', (
    $scope, $timeout, ComposerActions, ComposerListStore
)->
    ComposerListStore.listen (event, id)->
        $scope.$apply ->
            if event is EVENT.CHANGE
                $scope.composerPage = ComposerListStore.get id
            else if event is EVENT.ERROR
                $scope.error = ComposerListStore.getError()
                $timeout (-> $scope.error = null), ERROR_DISPLAY_TIME

    $scope.nextPage = ->
        ComposerActions.nextPage()

    $scope.prevPage = ->
        ComposerActions.prevPage()

    ComposerActions.loadPage()
