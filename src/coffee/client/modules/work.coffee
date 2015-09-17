#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular              = require 'angular'
templates            = require '../templates'
{DetailController}   = require '../base_controllers'
{PageableController} = require '../base_controllers'

############################################################################################################

work = angular.module 'work', ['dialog', 'schema']

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

        @refresh withRelations:['composer', 'instrument', 'type']
            .then =>
                $scope.$watch (=> @model), (=> @_updateFields())
                @_updateFields()

    beginEditing: ->
        return unless @_dialogController?
        @_dialogController.visible = true

    endEditing: ->
        return unless @_dialogController?
        @_dialogController.visible = false

    clearDialogController: (controller)->
        @_dialogController = null

    registerDialogController: (controller)->
        @_dialogController = controller

    _updateFields: ->
        @instrumentation = @model?.instrument?.name or 'unknown'
        @type            = @model?.type?.name       or 'unknown'
        @composed        = @model?.composed         or 'unknown'
        @difficulty      = @model?.difficulty       or 'unknown'

        @_dialogController.title = "Edit #{@model.title}" if @_dialogController?

        for field in ['instrumentation', 'type', 'composed', 'difficulty']
            @["#{field}Class"] = if @[field] is 'unknown' then 'no-value' else ''

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
