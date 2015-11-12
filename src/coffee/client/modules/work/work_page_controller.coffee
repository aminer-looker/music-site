#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular = require 'angular'

############################################################################################################

angular.module('work').controller 'WorkPageController', (
    $scope, WorkPageStore, WorkActions
)->
    WorkPageStore.$listen $scope, (event, pageNumber)->
        $scope.page = WorkPageStore.get()

    $scope.nextPage = ->
        WorkActions.nextPage()

    $scope.prevPage = ->
        WorkActions.prevPage()
