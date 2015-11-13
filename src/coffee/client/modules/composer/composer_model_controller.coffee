#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular = require 'angular'

############################################################################################################

angular.module('composer').controller 'ComposerModelController', (
    $scope, ComposerActions, ComposerModelStore, UrlUtils
)->
    ComposerModelStore.$listen $scope, (event, id)->
        $scope.composer = ComposerModelStore.get()

    ComposerActions.load UrlUtils.findId()
