#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular              = require 'angular'
_                    = require 'underscore'
{DIALOG_STATE}       = require '../../../constants'
{ERROR_DISPLAY_TIME} = require '../../../constants'
{EVENT}              = require '../../../constants'

############################################################################################################

angular.module('work').controller 'WorkModelController', (
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
