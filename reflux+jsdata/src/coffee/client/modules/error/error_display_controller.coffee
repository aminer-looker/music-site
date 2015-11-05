#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular = require 'angular'
{EVENT} = require '../../../constants'

############################################################################################################

angular.module('error').controller 'ErrorDisplayController', ($scope, ErrorActions, ErrorStore)->
    ErrorStore.listen (event, id)->
        return unless event is EVENT.CHANGE
        $scope.$apply ->
            $scope.errors = ErrorStore.getAll()

    $scope.dismiss = (id)->
        ErrorActions.removeError id
