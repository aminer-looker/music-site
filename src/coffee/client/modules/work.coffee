#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular              = require 'angular'
templates            = require '../templates'
{DetailController}   = require '../base_controllers'
{PageableController} = require '../base_controllers'

############################################################################################################

work = angular.module 'work', ['schema']

# Controllers ##########################################################################

work.controller 'WorkListController', class WorkListController extends PageableController

    constructor: ($scope, Work)->
        super $scope, Work

        $scope.$watch (-> $scope.composerId), (=> @refresh())

    _appendFilterTo: (options)->
        options.composer_id = @$scope.composerId
        return options

    _isConfigured: ->
        return @$scope.composerId?

work.controller 'WorkPageController', class WorkPageController extends DetailController

    constructor: ($scope, Work, $location)->
        super $scope, Work, $location
        @refresh()

# Directives ###########################################################################

work.directive 'workList', ->
    return {
        controller: 'WorkListController'
        controllerAs: 'controller'
        restrict: 'E'
        scope:
            composerId: '@'
        template: templates['work_list']
    }
