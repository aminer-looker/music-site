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
            @_ready = false

            $q.all Instrument.findAll(), Type.findAll()
                .then => @_ready = true

        # Public Methods ###########################################

        cancel: ->
            $q.when(true).then =>
                @model.DSRevert()
                return @model

        save: ->
            @model.DSSave().then =>
                return @model

        # Property Methods #########################################

        getComposedYear: ->
            return @model?.composed_year

        setComposedYear: (text)->
            value = parseInt text
            value = null if _.isNaN value
            @model.composed_year = value

        getDifficulty: ->
            return @model?.difficulty

        setDifficulty: (text)->
            value = parseFloat text
            value = null if _.isNaN value
            value = "#{Math.floor(value * 100) / 100}"
            @model.difficulty = value

        getInstrumentName: ->
            return @model?.instrument?.name

        setInstrumentName: (text)->
            throw new Error 'not supported'

        isReady: ->
            return @_ready

        getTitle: ->
            return @model?.title

        getType: ->
            return @model?.type?.name

        setType: ->
            throw new Error 'not supported'

        Object.defineProperties @prototype,
            composedYear:   { get:@::getComposedYear, set:@::setComposedYear }
            difficulty:     { get:@::getDifficulty, set:@::setDifficulty }
            instrumentName: { get:@::getInstrumentName, set:@::setInstrumentName }
            ready:          { get:@::isReady }
            title:          { get:@::getTitle }
            type:           { get:@::getType, set:@::setType }
