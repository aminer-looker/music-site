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
        return unless event is EVENT.CHANGE
        $scope.$apply ->
            $scope.composerPage = ComposerListStore.get id

    $scope.nextPage = ->
        ComposerActions.nextPage()

    $scope.prevPage = ->
        ComposerActions.prevPage()

    ComposerActions.loadPage()
