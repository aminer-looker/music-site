#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular = require 'angular'
{EVENT} = require '../../../constants'

############################################################################################################

angular.module('instrument').factory 'InstrumentListActions', (reflux)->
    reflux.createActions
        loadAll: { children: ['success', 'error'] }

# Stores ###################################################################################################

angular.module('instrument').factory 'InstrumentListStore', (
    ErrorActions, Instrument, InstrumentListActions, reflux
)->
    reflux.createStore
        init: ->
            @_instruments = []
            @listenToMany InstrumentListActions

        getAll: ->
            return @_instruments

        getError: ->
            return @_error

        onLoadAll: ->
            console.log "InstrumentListStore.onLoadAll()"
            Instrument.findAll()
                .then (instruments)->
                    InstrumentListActions.loadAll.success (i.toReadOnlyView() for i in instruments)
                .catch (error)->
                    InstrumentListActions.loadAll.error error

        onLoadAllSuccess: (instruments)->
            console.log "InstrumentListStore.onLoadSuccess(#{JSON.stringify(instruments)})"
            @_instruments = instruments
            @trigger EVENT.CHANGE

        onLoadAllError: (error)->
            console.log "InstrumentListStore.onLoadAllError(#{error})"
            @_error = error
            @trigger EVENT.ERROR
            ErrorActions.addError error
