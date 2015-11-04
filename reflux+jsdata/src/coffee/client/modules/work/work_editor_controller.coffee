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
    InstrumentListStore.listen (event, data)->
        console.log "WorkEditorController.InstrumentListStore.listen(#{event}, #{JSON.stringify(data)}"
        $scope.$apply ->
            if event is EVENT.CHANGE
                $scope.instruments = data
            else if event is EVENT.ERROR
                $scope.error = data
                $timeout (-> $scope.error = null), ERROR_DISPLAY_TIME

    TypeListStore.listen (event, data)->
        console.log "WorkEditorController.TypeListStore.listen(#{event}, #{JSON.stringify(data)}"
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
