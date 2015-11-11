#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular = require 'angular'

############################################################################################################

angular.module('composer').controller 'ComposerListController', (
    $scope, ComposerActions, ComposerListStore
)->
    ComposerListStore.$listen $scope, (event, id)->
        $scope.composerPage = ComposerListStore.get id

    $scope.nextPage = ->
        ComposerActions.nextPage()

    $scope.prevPage = ->
        ComposerActions.prevPage()

    ComposerActions.loadPage()
