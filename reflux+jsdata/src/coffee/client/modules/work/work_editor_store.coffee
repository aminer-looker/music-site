#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular = require 'angular'
_       = require 'underscore'
{EVENT} = require '../../../constants'

############################################################################################################

angular.module('work').factory 'WorkEditorActions', (reflux)->
    actions = reflux.createActions
        beginEditing: { children: ['success', 'error'] }
        save: { children: ['success', 'error']}
        cancel: {}

    actions = _.extend actions, reflux.createActions [
        'setComposedYear', 'setDifficulty', 'setInstrumentId', 'setTypeId'
    ]

    return actions

############################################################################################################

angular.module('work').factory 'WorkEditorStore', (
    ErrorActions, InstrumentActions, InstrumentListStore, reflux,
    TypeActions, TypeListStore, Work, WorkEditorActions
)->
    reflux.createStore
        init: ->
            @_editing          = false
            @_error            = null
            @_validationErrors = {}
            @_workModel        = null
            @_workView         = null

            @listenToMany WorkEditorActions
            InstrumentActions.loadAll()
            TypeActions.loadAll()

        get: ->
            return @_workView

        getError: ->
            return @_error

        getValidationErrors: ->
            return _.clone @_validationErrors

        isEditing: ->
            return @_isEditing

        isValid: ->
            for field, errors of @_validationErrors
                return false if errors.length > 0
            return true

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
            console.log "WorkEditorStore.onBeginEditingSuccess(#{id}, #{JSON.stringify(model.toJSON())})"
            @_error            = null
            @_isEditing        = true
            @_validationErrors = {}
            @_workModel        = model

            @_workView = model.toReadOnlyView()
            @_workView.setActions
                composed_year: WorkEditorActions.setComposedYear,
                difficulty:    WorkEditorActions.setDifficulty,
                instrument_id: WorkEditorActions.setInstrumentId,
                type_id:       WorkEditorActions.setTypeId

            @trigger EVENT.ERROR, id
            @trigger EVENT.INVALID, id
            @trigger EVENT.CHANGE, id

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

            @_workModel.mergeChanges @_workView
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

        onSetComposedYear: (view, field, value, commit)->
            console.log "WorkEditorStore.onSetComposedYear(#{view.id}, #{field}, #{value}, func)"
            return unless view.id is @_workView.id

            @_markValid field

            value = value.trim()
            if value.length is 0
                value = null
            else
                numberValue = parseInt value
                currentYear = new Date().getFullYear()
                if not _.isNumber(numberValue) then @_markInvalid field, 'must be a number'
                if not numberValue > 0 then @_markInvalid field, 'must be greater than 0'
                if numberValue > currentYear then @_markInvalid field, 'cannot be in the future'

            commit value
            @trigger EVENT.CHANGE, @_workView.id

        onSetDifficulty: (view, field, value, commit)->
            console.log "WorkEditorStore.onSetDifficulty(#{view.id}, #{field}, #{value}, func)"
            return unless view.id is @_workView.id

            @_markValid field

            value = value.trim()
            if value.length is 0
                value = null
            else
                numberValue = parseFloat value
                if _.isNaN(numberValue) then @_markInvalid field, 'must be a number'
                if numberValue < 0 then @_markInvalid field, 'must be at least 0.00'
                if numberValue > 100.00 then @_markInvalid field, 'must be no more than 100.00'

            commit value
            @trigger EVENT.CHANGE, @_workView.id

        onSetInstrumentId: (view, field, value, commit)->
            console.log "WorkEditorStore.onSetInstrumentId(#{view.id}, #{field}, #{value}, func)"
            return unless view.id is @_workView.id

            @_markValid field

            valid = false
            for instrument in InstrumentListStore.getAll()
                if instrument.id is value
                    valid = true
                    break
            if not valid then @_markInvalid field, 'must be a valid instrument'

            commit value
            @trigger EVENT.CHANGE, @_workView.id

        onSetTypeId: (view, field, value, commit)->
            console.log "WorkEditorStore.onSetTypeId(#{view.id}, #{field}, #{value}, func)"
            return unless view.id is @_workView.id

            @_markValid field

            valid = false
            for type in TypeListStore.getAll()
                if type.id is value
                    valid = true
                    break
            if not valid then @_markInvalid field, 'must be a valid type'

            commit value
            @trigger EVENT.CHANGE, @_workView.id

        # Private Methods ##############################################################

        _markInvalid: (field, message)->
            errorList = @_validationErrors[field]
            if not errorList
                errorList = @_validationErrors[field] = []

            return if message in errorList
            errorList.push message

            @trigger EVENT.INVALID, @_workView.id

        _markValid: (field)->
            return unless @_validationErrors[field]?
            return unless @_validationErrors[field].length > 0

            delete @_validationErrors[field]
            @trigger EVENT.INVALID, @_workView.id
