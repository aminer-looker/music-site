#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular              = require 'angular'
{ERROR_DISPLAY_TIME} = require '../../../constants'
{EVENT}              = require '../../../constants'

############################################################################################################

angular.module('work').controller 'WorkEditorController', (
    $scope, $timeout, InstrumentActions, InstrumentListStore,
    TypeActions, TypeListStore, WorkEditorStore, WorkActions
)->
    InstrumentListStore.listen (event)->
        console.log "WorkEditorController.InstrumentListStore.listen(#{event})}"
        return unless event is EVENT.CHANGE
        $scope.$apply ->
            $scope.instruments = InstrumentListStore.getAll()

    TypeListStore.listen (event)->
        console.log "WorkEditorController.TypeListStore.listen(#{event})"
        return unless event is EVENT.CHANGE

        $scope.$apply ->
            if event is EVENT.CHANGE
                $scope.types = TypeListStore.getAll()

    WorkEditorStore.listen (event, id)->
        console.log "WorkEditorController.WorkEditorStore.listen(#{event}, #{id})"
        return if $scope.work? and id isnt $scope.work.id

        $scope.$apply ->
            if event is EVENT.CHANGE
                $scope.work = WorkEditorStore.get()
            else if event is EVENT.INVALID
                $scope.isValid = WorkEditorStore.isValid()
                $scope.errors = WorkEditorStore.getValidationErrors()

    $scope.save = ->
        WorkActions.save()

    $scope.cancel = ->
        WorkActions.cancel()

    InstrumentActions.loadAll()
    TypeActions.loadAll()
