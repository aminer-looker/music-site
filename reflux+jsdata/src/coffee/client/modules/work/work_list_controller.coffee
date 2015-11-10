#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular = require 'angular'

############################################################################################################

angular.module('work').controller 'WorkListController', (
    $scope, WorkListStore, WorkActions
)->
    WorkListStore.$listen $scope, (event, pageNumber)->
        $scope.page = WorkListStore.get()

    $scope.nextPage = ->
        WorkActions.nextPage()

    $scope.prevPage = ->
        WorkActions.prevPage()
