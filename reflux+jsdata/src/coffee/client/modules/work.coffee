#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular              = require 'angular'
templates            = require '../templates'
_                    = require 'underscore'
{DIALOG_STATE}       = require '../../constants'
{ERROR_DISPLAY_TIME} = require '../../constants'
{EVENT}              = require '../../constants'
{EVENT}              = require '../../constants'
{PAGE_SIZE}          = require '../../constants'

############################################################################################################

module = angular.module 'work', ['composer', 'dialog', 'instrument', 'page', 'reflux', 'schema', 'type']

# Actions ##################################################################################################

module.factory 'WorkEditorActions', (reflux)->
    reflux.createActions
        beginEditing: { children: ['success', 'error'] }
        cancel: {}
        save: { children: ['success', 'error']}

########################################################################################

module.factory 'WorkListActions', (reflux)->
    reflux.createActions
        loadPage: { children: ['success', 'error'] }
        nextPage: {}
        prevPage: {}

########################################################################################

module.factory 'WorkModelActions', (reflux)->
    reflux.createActions
        load: { children: ['success', 'error'] }

########################################################################################

module.factory 'WorkActions', (WorkEditorActions, WorkListActions, WorkModelActions)->
    _.extend {}, WorkEditorActions, WorkListActions, WorkModelActions

# Controllers ##############################################################################################

module.controller 'WorkEditorController', (
    $scope, $timeout, InstrumentActions, InstrumentStore,
    TypeActions, TypeStore, WorkEditorStore, WorkActions
)->
    InstrumentStore.listen (event, data)->
        console.log "WorkEditorController.InstrumentStore.listen(#{event}, #{JSON.stringify(data)}"
        $scope.$apply ->
            if event is EVENT.CHANGE
                $scope.instruments = data
            else if event is EVENT.ERROR
                $scope.error = data
                $timeout (-> $scope.error = null), ERROR_DISPLAY_TIME

    TypeStore.listen (event, data)->
        console.log "WorkEditorController.TypeStore.listen(#{event}, #{JSON.stringify(data)}"
        return unless event is EVENT.CHANGE

        $scope.$apply ->
            if event is EVENT.CHANGE
                $scope.types = data
            else if event is EVENT.ERROR
                $scope.error = data
                $timeout (-> $scope.error = null), ERROR_DISPLAY_TIME

    WorkEditorStore.listen (event, id, data)->
        console.log "WorkEditorController.WorkEditorStore.listen(#{event}, #{id}, #{JSON.stringify(data)})"
        return if $scope.work? and id isnt $scope.work.id

        $scope.$apply ->
            if event is EVENT.CHANGE
                $scope.work = data
            else if event is EVENT.ERROR
                $scope.error = data
                $timeout (-> $scope.error = null), ERROR_DISPLAY_TIME

    $scope.save = ->
        WorkActions.save()

    $scope.cancel = ->
        WorkActions.cancel()

    InstrumentActions.loadAll()
    TypeActions.loadAll()

########################################################################################

module.controller 'WorkListController', ($scope, $timeout, WorkEditorStore, WorkListStore, WorkActions)->
    WorkListStore.listen (event, pageNumber, data)->
        $scope.$apply ->
            if event is EVENT.CHANGE
                $scope.page = data
            else if event is EVENT.ERROR
                $scope.error = data
                $timeout (-> $scope.error = null), ERROR_DISPLAY_TIME

    $scope.nextPage = ->
        WorkActions.nextPage()

    $scope.prevPage = ->
        WorkActions.prevPage()

########################################################################################

module.controller 'WorkModelController', (
    $location, $scope, $timeout, DialogActions, DialogStore, WorkEditorStore, WorkModelStore, WorkActions
)->
    WorkModelStore.listen (event, id, data)->
        console.log "WorkModelController.WorkModelStore.listen(#{event}, #{id}, #{JSON.stringify(data)})"
        $scope.$apply ->
            if event is EVENT.CHANGE
                $scope.work = data
            else if event is EVENT.ERROR
                $scope.error = data
                $timeout (-> $scope.error = null), ERROR_DISPLAY_TIME

    WorkEditorStore.listen (event, id, data)->
        console.log "WorkModelController.WorkEditorStore.listen(#{event}, #{id}, #{JSON.stringify(data)})"
        $scope.$apply ->
            if event is EVENT.CHANGE
                DialogActions.setTitle $scope.dialogName, "Edit #{data.title}"
            else if event is EVENT.DONE
                DialogActions.close $scope.dialogName
            else if event is EVENT.ERROR
                $scope.error = data
                $timeout (-> $scope.error = null), ERROR_DISPLAY_TIME

    DialogStore.listen (event, name)->
        console.log "WorkModelController.DialogStore.listen(#{event}, #{name})"
        return unless event is EVENT.CHANGE
        return unless name is $scope.dialogName

        $scope.$apply ->
            dialogData = DialogStore.get name
            if dialogData.state is DIALOG_STATE.CLOSED
                WorkActions.cancel()

    $scope.dialogName = 'work-editor'
    $scope.dialogTitle = ''

    $scope.beginEditing = ->
        return unless $scope.work?
        console.log "$scope.beginEditing()"
        console.log "    $scope.work: #{JSON.stringify($scope.work)}"

        WorkActions.beginEditing $scope.work.id
        DialogActions.open $scope.dialogName

    readLocationForId = ->
        match = /.*\/(.*)$/.exec $location.path()
        return null unless match?

        id = parseInt match[1]
        return null unless _.isNumber id

        return id

    WorkActions.load readLocationForId()

# Directives ###############################################################################################

module.directive 'workEditor', ->
    controller: 'WorkEditorController'
    controllerAs: 'controller'
    restrict: 'E'
    scope:
        id: '&'
    template: templates['work_editor']

########################################################################################

module.directive 'workList', ->
    controller: 'WorkListController'
    controllerAs: 'controller'
    restrict: 'E'
    scope: {}
    template: templates['work_list']

# Stores ###################################################################################################

module.factory 'WorkEditorStore', (reflux, Work, WorkEditorActions)->
    reflux.createStore
        init: ->
            @_editing   = false
            @_error     = null
            @_workModel = null
            @_workView  = null

            @listenToMany WorkEditorActions

        get: ->
            return @_workView

        getError: ->
            return @_error

        isEditing: ->
            return @_isEditing

        onBeginEditing: (id)->
            return unless id?
            console.log "WorkEditorStore.onBeginEditing(#{id})"

            @_isEditing = false
            Work.find id
                .then (model)->
                    WorkEditorActions.beginEditing.success id, model
                .catch (error)->
                    WorkEditorActions.beginEditing.error id, error

        onBeginEditingSuccess: (id, model)->
            console.log "WorkEditorStore.onBeginEditingSuccess(#{id}, #{JSON.stringify(model.toView())})"
            @_error     = null
            @_isEditing = true
            @_workModel = model
            @_workView  = model.toView()

            @trigger EVENT.ERROR, id, null
            @trigger EVENT.CHANGE, id, @_workView

        onBeginEditingError: (id, error)->
            console.log "WorkEditorStore.onBeginEditingError(#{id}, #{error})"
            @_error = error

            @trigger EVENT.ERROR, id, error
            @trigger EVENT.DONE

        onCancel: ->
            return unless @isEditing()
            console.log "WorkEditorStore.onCancel()"
            @_isEditing = false

            @trigger EVENT.CHANGE, @_workView.id, @_workView
            @trigger EVENT.DONE

        onSave: ->
            return unless @isEditing()
            console.log "WorkEditorStore.onSave()"

            @_workModel.mergeView @_workView
            @_workModel.DSSave()
                .then =>
                    WorkEditorActions.save.success @_workView.id, @_workView
                .catch (error)=>
                    WorkEditorActions.save.error @_workView.id, error

        onSaveSuccess: (id, view)->
            console.log "WorkEditorStore.onSaveSuccess(#{id}, #{JSON.stringify(view)})"
            @_error     = null
            @_isEditing = false

            @trigger EVENT.ERROR, id, null
            @trigger EVENT.SAVE, id, view
            @trigger EVENT.DONE, id, view

        onSaveError: (id, error)->
            console.log "WorkEditorStore.onSaveError(#{id}, #{JSON.stringify(error)})"
            @_error = error

            @trigger EVENT.ERROR, id, error
            @trigger EVENT.DONE, id, null

########################################################################################

module.factory 'WorkListStore', ($q, ComposerModelStore, Page, reflux, Work, WorkListActions)->
    reflux.createStore
        init: ->
            ComposerModelStore.listen (event, id, data)=>
                if event is EVENT.CHANGE and id isnt @_composerId
                    @_composerId = id
                    WorkListActions.loadPage()

            @_composerId = null
            @_page = null
            @listenToMany WorkListActions

        get: ->
            return @_page

        onLoadPage: (pageNumber)->
            return unless @_composerId?

            pageNumber ?= 0
            total = null
            list = null

            $q.when(true)
                .then =>
                    Work.count composer_id:@_composerId
                .then (count)=>
                    total  = count
                    offset = pageNumber * PAGE_SIZE
                    limit  = PAGE_SIZE
                    Work.findAll composer_id:@_composerId, offset:offset, limit:limit
                .then (works)->
                    list = (w.toView() for w in works)
                    totalPages = Math.ceil total / PAGE_SIZE
                    WorkListActions.loadPage.success pageNumber, totalPages, list
                .catch (error)->
                    WorkListActions.loadPage.error pageNumber, error

        onLoadPageError: (pageNumber, error)->
            @trigger EVENT.ERROR, pageNumber, error

        onLoadPageSuccess: (pageNumber, totalPages, list)->
            @_page = new Page pageNumber, totalPages, list
            @trigger EVENT.CHANGE, pageNumber, @_page

        onNextPage: ->
            if @_page?
                return unless @_page.hasNextPage()
                pageNumber = @_page.pageNumber + 1
            else
                pageNumber = 0

            WorkListActions.loadPage pageNumber

        onPrevPage: ->
            if @_page?
                return unless @_page.hasPrevPage()
                pageNumber = @_page.pageNumber - 1
            else
                pageNumber = 0

            WorkListActions.loadPage pageNumber

########################################################################################

module.factory 'WorkModelStore', (Work, WorkEditorStore, WorkModelActions, reflux)->
    reflux.createStore
        init: ->
            WorkEditorStore.listen (event, id, data)=>
                console.log "WorkModelStore.WorkEditorStore.listen(#{event}, #{id}, #{JSON.stringify(data)})"
                return unless event is EVENT.SAVE
                return unless @_work? and id is @_work.id
                WorkModelActions.load id

            @_work = null
            @listenToMany WorkModelActions

        get: ->
            return @_work

        onLoad: (id)->
            console.log "WorkModelStore.onLoad(#{id})"
            relations = ['composer', 'instrument', 'type']

            Work.find id
                .then (work)->
                    Work.loadRelations work, relations
                .then (work)->
                    WorkModelActions.load.success id, work.toView relations:relations
                .catch (error)->
                    WorkModelActions.load.error id, error

        onLoadSuccess: (id, work)->
            console.log "WorkModelStore.onLoadSuccess(#{id}, #{JSON.stringify(work)})"
            @_work = work
            @trigger EVENT.CHANGE, id, work

        onLoadError: (id, error)->
            console.log "WorkModelStore.onLoadError(#{id}, #{JSON.stringify(error)})"
            @trigger EVENT.ERROR, id, error
