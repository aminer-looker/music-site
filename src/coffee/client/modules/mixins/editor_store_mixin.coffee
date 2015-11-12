#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

_            = require '../../../underscore'
angular      = require 'angular'
{EVENT}      = require '../../../constants'
ReadOnlyView = require '../../../read_only_view'

############################################################################################################

angular.module('mixins').factory 'addEditorStoreMixinActions', (reflux)->
    return (actions, fields)->
        fieldActions = {}
        for field in fields
            fieldActions["set#{_.camelize(field)}"] = reflux.createAction fieldName:field

        return _.extend actions, fieldActions, reflux.createActions
            beginEditing: { children: ['success', 'error'] }
            save: { children: ['success', 'error']}
            cancel: {}

############################################################################################################

angular.module('mixins').factory 'EditorStoreMixin', (ErrorActions)->

    init: ->
        @_editing          = false
        @_error            = null
        @_validationErrors = {}
        @_model            = null
        @_view             = null

        allActions = _.gatherProperties @listenables

        if not allActions.beginEditing?.error?
            throw new Error 'EditorStoreMixin requires a beginEditing.error action'
        if not allActions.beginEditing?.success?
            throw new Error 'EditorStoreMixin requires a beginEditing.success action'
        if not allActions.save?.error?
            throw new Error 'EditorStoreMixin requires a save.error action'
        if not allActions.save?.success?
            throw new Error 'EditorStoreMixin requires a save.success action'

        for actionName, action of allActions
            continue unless action.fieldName?
            this["onSet#{_.camelize(action.fieldName)}"] = (view, field, value, commit)=>
                @_onFieldChanged view, field, value, commit

        @_fireBeginEditingError   = allActions.beginEditing.error
        @_fireBeginEditingSuccess = allActions.beginEditing.success
        @_fireSavegError          = allActions.save.error
        @_fireSaveSuccess         = allActions.save.success

    # Override Methods #################################################################

    _loadModel: (id)->
        # Subclasses must override this method to return a promise of the model object specified by the
        # given `id`.  The caller can deal with either a "resolved" or "rejected" promise.
        throw new Error 'EditorStoreMixin requires _loadModel'

    _saveModel: (view, model)->
        # Subclasses must override this method to update the model with data given in the view, and then to
        # take whatever steps are necessary to persist that change.  The subclass should then return a
        # a promise of the updated model object.  The caller will be able to deal with either a "resolved"
        # or "rejected" promise.
        throw new Error 'EditorStoreMixin requires _saveModel'

    # _validate<FieldName>(value, errors)->
    #     # Subclasses may add validation methods for each "set..." action in this store's listenables.  If
    #     # such a method exists, it will be called whenever the associated field changes.  If any
    #     # validation errors are detected, they may be pushed into the `errors` array.  The subclass must
    #     # return the new value to be used for the field (even if it's just to return the same `value`).
    #
    #     if parseInt(value) % 2 is 1 then errors.push 'no odd numbers!'
    #     return value

    # Public Methods ###################################################################

    get: ->
        return @_view

    getError: ->
        return @_error

    getValidationErrors: ->
        return _.clone @_validationErrors

    isEditing: ->
        return @_isEditing

    isValid: (field=null)->
        valid = true

        if field?
            valid = @_validationErrors[field]?.length > 0
        else
            for field, errors of @_validationErrors
                if errors.length > 0
                    valid = false
                    break

        return valid

    # Action Methods ###################################################################

    onBeginEditing: (id)->
        return unless id?

        @_isEditing = false
        @_loadModel id
            .then (model)=>
                @_fireBeginEditingSuccess id, model
            .catch (error)=>
                @_fireBeginEditingError id, error

    onBeginEditingError: (id, error)->
        @_error = error

        @trigger EVENT.ERROR, id
        @trigger EVENT.DONE, id
        ErrorActions.addError error

    onBeginEditingSuccess: (id, model)->
        @_error            = null
        @_isEditing        = true
        @_validationErrors = {}
        @_model            = model
        @_view             = ReadOnlyView.convertObject model

        for actionName, action of _.gatherProperties @listenables
            continue unless action.fieldName?
            @_view.setAction action.fieldName, action

        @trigger EVENT.ERROR, id
        @trigger EVENT.INVALID, id
        @trigger EVENT.CHANGE, id

    onCancel: ->
        return unless @isEditing()
        @_isEditing = false

        @trigger EVENT.CHANGE, @_view.id
        @trigger EVENT.DONE, @_view.id

    onSave: ->
        return unless @isEditing()

        @_saveModel @_view, @_model
            .then =>
                @_fireSaveSuccess @_view.id, @_view
            .catch (error)=>
                @_fireSaveError @_view.id, error

    onSaveError: (id, error)->
        @_error = error

        @trigger EVENT.ERROR, id
        @trigger EVENT.DONE, id
        ErrorActions.addError error

    onSaveSuccess: (id, view)->
        @_error     = null
        @_isEditing = false

        @trigger EVENT.ERROR, id
        @trigger EVENT.SAVE, id
        @trigger EVENT.DONE, id

    # Private Methods ##################################################################

    _onFieldChanged: (view, field, value, commit)->
        return unless view.id is @_view.id

        @_markValid field

        value = if _.isString(value) then value.trim() else value
        if value.length is 0
            value = null

        methodName = "_validate#{_.camelize(field)}"
        if _.isFunction this[methodName]
            errors = []
            value = this[methodName](value, errors)
            @_markInvalid field, errors

        commit value
        @trigger EVENT.CHANGE, @_view.id

    _markInvalid: (field, messages)->
        return unless messages.length > 0

        errorList = @_validationErrors[field] ?= []

        addedError = false
        for message in messages
            continue if message in errorList
            errorList.push message
            addedError = true

        if addedError then @trigger EVENT.INVALID, @_view.id

    _markValid: (field)->
        return unless @_validationErrors[field]?
        return unless @_validationErrors[field].length > 0

        delete @_validationErrors[field]
        @trigger EVENT.INVALID, @_view.id
