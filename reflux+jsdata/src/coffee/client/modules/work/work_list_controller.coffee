#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular              = require 'angular'
{ERROR_DISPLAY_TIME} = require '../../../constants'
{EVENT}              = require '../../../constants'

############################################################################################################

angular.module('work').controller 'WorkListController', (
    $scope, $timeout, WorkEditorStore, WorkListStore, WorkActions
)->
    WorkListStore.listen (event, pageNumber)->
        return unless event is EVENT.CHANGE

        $scope.$apply ->
            $scope.page = WorkListStore.get()

    $scope.nextPage = ->
        WorkActions.nextPage()

    $scope.prevPage = ->
        WorkActions.prevPage()
