#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular = require 'angular'
{EVENT} = require '../../../constants'

############################################################################################################

angular.module('work').factory 'WorkEditorActions', (reflux)->
    reflux.createActions
        beginEditing: { children: ['success', 'error'] }
        cancel: {}
        save: { children: ['success', 'error']}

############################################################################################################

angular.module('work').factory 'WorkEditorStore', (ErrorActions, reflux, Work, WorkEditorActions)->
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
            console.log "WorkEditorStore.onBeginEditing(#{id})"
            return unless id?

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

            @trigger EVENT.CHANGE, id
            @trigger EVENT.ERROR, id

        onBeginEditingError: (id, error)->
            console.log "WorkEditorStore.onBeginEditingError(#{id}, #{error})"
            @_error = error

            @trigger EVENT.ERROR, id
            @trigger EVENT.DONE, id
            ErrorActions.addError error

        onCancel: ->
            console.log "WorkEditorStore.onCancel()"
            return unless @isEditing()
            @_isEditing = false

            @trigger EVENT.CHANGE, @_workView.id
            @trigger EVENT.DONE, @_workView.id

        onSave: ->
            console.log "WorkEditorStore.onSave()"
            return unless @isEditing()

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

            @trigger EVENT.ERROR, id
            @trigger EVENT.SAVE, id
            @trigger EVENT.DONE, id

        onSaveError: (id, error)->
            console.log "WorkEditorStore.onSaveError(#{id}, #{JSON.stringify(error)})"
            @_error = error

            @trigger EVENT.ERROR, id
            @trigger EVENT.DONE, id
            ErrorActions.addError {message:"Could not save. Please try again later."}
