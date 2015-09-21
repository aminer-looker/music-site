#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

_                    = require 'underscore'
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

    constructor: ($scope, Work, $location, WorkEditor)->
        super $scope, Work, $location
        @$scope = $scope

        @refresh withRelations:['composer', 'instrument', 'type']
            .then =>
                @editor = new WorkEditor @model

    beginEditing: ->
        return unless @_dialogController?
        return unless @_editorController?

        @_editorController.beginEditing @editor
            .then =>
                @_dialogController.close()
            .catch =>
                @_dialogController.close()

        @_dialogController.visible = true

    cancel: ->
        return unless @_editorController?
        @_editorController.cancel()

    canCloseDialog: (dialogController)->
        return true unless @_editorController.editing?
        @_editorController.cancel()
        return false

    registerDialogController: (controller)->
        @_dialogController = controller
        assignTitle = => @_dialogController.title = "Edit #{@editor?.title}"
        @$scope.$watch (=> @editor?.title ), assignTitle
        assignTitle()

    registerEditorController: (editor)->
        @_editorController = editor

    save: ->
        return unless @_editorController?
        @_editorController.save()

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

# Factories ############################################################################

work.factory 'WorkEditor', ($q, Instrument, Type, Work)->

    class WorkEditor

        constructor: (@model)->
            @isReady = false
            @instruments = @types = null

            $q.all instruments:Instrument.findAll(), types:Type.findAll()
                .then (result)=>
                    @instruments = result.instruments
                    @types = result.types
                    @isReady = true

        # Public Methods ###########################################

        cancel: ->
            $q.when(true).then =>
                @model.DSRevert()
                return @model

        save: ->
            @model.DSSave().then =>
                return @model

        # Property Methods #########################################

        Object.defineProperties @prototype,
            composedYear:
                get: -> @model?.composed_year
                set: (text)->
                    value = parseInt text
                    value = null if _.isNaN value
                    @model.composed_year = value
            difficulty:
                get: -> @model?.difficulty
                set: (text)->
                    value = parseFloat text
                    value = null if _.isNaN value
                    value = "#{Math.floor(value * 100) / 100}"
                    @model.difficulty = value
            instrumentId:
                get: -> @model?.instrument?.id
                set: (id)-> @model.instrument_id = id
            instrumentName:
                get: -> @model?.instrument?.name
            title:
                get: -> @model?.title
            typeName:
                get: -> @model?.type?.name
            typeId:
                get: -> @model?.type?.id
                set: (id)-> @model.type_id = id
