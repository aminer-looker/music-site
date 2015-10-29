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

work = angular.module 'work', ['dialog', 'editor', 'schema']

# Controllers ##########################################################################

work.controller 'WorkListController', class WorkListController extends PageableController

    constructor: ($scope, WorkStore, WorkActions)->
        super $scope, WorkStore, WorkActions

        $scope.$watch (-> $scope.composerId), (=> @refresh())

    _appendFilterTo: (options)->
        options.composer_id = @$scope.composerId
        return options

    _isConfigured: ->
        return @$scope.composerId?

work.controller 'WorkPageController', class WorkPageController extends DetailController

    constructor: ($scope, WorkStore, $location, WorkEditor)->
        super $scope, WorkStore, $location
        @$scope = $scope
        @subscribe withRelations:['composer', 'instrument', 'type']

    beginEditing: ->
        return unless @_dialogController?
        return unless @_editorController?

        @_editorController.beginEditing @store.get @model.id
            .finally =>
                @_dialogController.close()

        @_dialogController.open()

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

work.factory 'WorkActions', (reflux)->
    reflux.createActions [
        'load'
        'update'
    ]

work.factory 'WorkStore', (reflux, Work, WorkActions, WorkEditor)->
    reflux.createStore
        init: ->
            @Resource = Work
            @Editor = WorkEditor

        listenables: WorkActions

work.factory 'WorkEditor', (InstrumentStore, TypeStore, Work, WorkActions)->

    class WorkEditor

        constructor: (model)->
            @data        = {}
            @instruments = InstrumentStore.getAll()
            @types       = TypeStore.getAll()
            @_model      = model

            InstrumentStore.listen => @instruments = InstrumentStore.getAll()
            InstrumentStore.loadAll()

            TypeStore.listen => @types = TypeStore.getAll()
            TypeStore.loadAll()

        # Public Methods ###########################################

        cancel: ->
            # do nothing

        save: ->
            WorkActions.update @data

        # Property Methods #########################################

        Object.defineProperties @prototype,
            composedYear:
                get: -> @data.composed_year ?= @model?.composed_year
                set: (text)->
                    value = parseInt text
                    value = null if _.isNaN value
                    @data.composed_year = value
            difficulty:
                get: -> @data.difficulty ?= @model?.difficulty
                set: (text)->
                    value = parseFloat text
                    value = null if _.isNaN value
                    value = "#{Math.floor(value * 100) / 100}"
                    @data.difficulty = value
            instrumentId:
                get: -> @data.instrument_id ?= @model?.instrument?.id
                set: (id)-> @data.instrument_id = id
            instrumentName:
                get: -> @model?.instrument?.name
            isReady:
                get: -> @instruments? and @types?
            title:
                get: -> @model?.title
            typeName:
                get: -> @model?.type?.name
            typeId:
                get: -> @data.type_id ?= @model?.type?.id
                set: (id)-> @data.type_id = id
