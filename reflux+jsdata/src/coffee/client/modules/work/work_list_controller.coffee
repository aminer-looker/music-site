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
        $scope.$apply ->
            if event is EVENT.CHANGE
                $scope.page = WorkListStore.get()
            else if event is EVENT.ERROR
                $scope.error = WorkListStore.getError()
                $timeout (-> $scope.error = null), ERROR_DISPLAY_TIME

    $scope.nextPage = ->
        WorkActions.nextPage()

    $scope.prevPage = ->
        WorkActions.prevPage()
