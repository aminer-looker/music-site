#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular = require 'angular'
_       = require '../../../underscore'

############################################################################################################

FIELDS = ['composed_year', 'difficulty', 'instrument_id', 'type_id']
ACTION_NAMES = _.object([field, "set#{_.camelize(field)}"] for field in FIELDS)

############################################################################################################

angular.module('work').factory 'WorkEditorActions', (reflux)->
    actions = reflux.createActions
        beginEditing: { children: ['success', 'error'] }
        save: { children: ['success', 'error']}
        cancel: {}

    _.extend actions, reflux.createActions (ACTION_NAMES[field] for field in FIELDS)

############################################################################################################

angular.module('work').factory 'WorkEditorStore', (
    EditorStoreMixin, InstrumentActions, reflux, TypeActions, Work, WorkEditorActions
)->
    reflux.createStore
        init: ->
            @_actions = WorkEditorActions
            @listenToMany @_actions

            InstrumentActions.loadAll()
            TypeActions.loadAll()

        mixins: [EditorStoreMixin]

        # Private Methods ##############################################################

        _getUpdateActions: ->
            fields = ['composed_year', 'difficulty', 'instrument_id', 'type_id']
            result = {}
            for field in fields
                result[field] = WorkEditorActions["set#{_.camelize(field)}"]
            return result

        _loadModel: (id)->
            return Work.find id

        _saveModel: (view, model)->
            model.mergeChanges view
            return model.DSSave()

        _validateComposedYear: (value, errors)->
            numberValue = parseInt value
            currentYear = new Date().getFullYear()
            if not _.isNumber(numberValue) then errors.push 'must be a number'
            if not numberValue > 0 then errors.push 'must be greater than 0'
            if numberValue > currentYear then errors.push 'cannot be in the future'
            return value

        _validateDifficulty: (value, errors)->
            numberValue = parseFloat value
            if _.isNaN(numberValue) then errors.push 'must be a number'
            if numberValue < 0 then errors.push 'must be at least 0.00'
            if numberValue > 100.00 then errors.push 'must be no more than 100.00'
            return value

        _validateInstrumentId: (value, errors)->
            for instrument in InstrumentListStore.getAll()
                if instrument.id is value
                    return value

            errors.push 'must be a valid instrument'
            return null

        _validateTypeId: (value, errors)->
            for type in TypeListStore.getAll()
                if type.id is value
                    return value

            errors.push 'must be a valid type'
            return null
