#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular = require 'angular'

############################################################################################################

angular.module('composer').controller 'ComposerPageController', (
    $scope, ComposerActions, ComposerPageStore
)->
    ComposerPageStore.$listen $scope, (event, id)->
        $scope.composerPage = ComposerPageStore.get id

    $scope.nextPage = ->
        ComposerActions.nextPage()

    $scope.prevPage = ->
        ComposerActions.prevPage()

    ComposerActions.loadPage()
