#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular = require 'angular'

############################################################################################################

angular.module('error').controller 'ErrorDisplayController', ($scope, ErrorActions, ErrorStore)->
    ErrorStore.$listen $scope, (event, id)->
        $scope.errors = ErrorStore.getAll()

    $scope.dismiss = (id)->
        ErrorActions.removeError id
