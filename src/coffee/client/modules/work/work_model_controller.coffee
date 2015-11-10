#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular        = require 'angular'
_              = require 'underscore'
{DIALOG_STATE} = require '../../../constants'
{EVENT}        = require '../../../constants'

############################################################################################################

angular.module('work').controller 'WorkModelController', (
    $location, $scope, DialogActions, DialogStore, WorkEditorStore, WorkModelStore, WorkActions
)->
    WorkModelStore.$listen $scope, (event, id)->
        $scope.work = WorkModelStore.get()

    WorkEditorStore.$listen $scope, (event, id)->
        if event is EVENT.CHANGE
            work = WorkEditorStore.get()
            DialogActions.setTitle $scope.dialogName, "Edit #{work.title}"
        else if event is EVENT.DONE
            DialogActions.close $scope.dialogName

    DialogStore.$listen $scope, (event, name)->
        return unless name is $scope.dialogName

        dialogData = DialogStore.get name
        if dialogData.state is DIALOG_STATE.CLOSED
            WorkActions.cancel()

    $scope.dialogName = 'work-editor'

    $scope.beginEditing = ->
        return unless $scope.work?

        WorkActions.beginEditing $scope.work.id
        DialogActions.open $scope.dialogName

    readLocationForId = ->
        match = /.*\/(.*)$/.exec $location.path()
        return null unless match?

        id = parseInt match[1]
        return null unless _.isNumber id

        return id

    WorkActions.load readLocationForId()
