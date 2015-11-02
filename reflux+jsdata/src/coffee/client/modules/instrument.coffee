#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular = require 'angular'
{EVENT} = require '../../constants'

############################################################################################################

module = angular.module 'instrument', ['reflux', 'schema']

# Actions ##################################################################################################

module.factory 'InstrumentActions', (reflux)->
    reflux.createActions
        loadAll: { children: ['success', 'error'] }

# Stores ###################################################################################################

module.factory 'InstrumentStore', (Instrument, InstrumentActions, reflux)->
    reflux.createStore
        init: ->
            @_instruments = []
            @listenToMany InstrumentActions

        getAll: ->
            return @_instruments

        getError: ->
            return @_error

        onLoadAll: ->
            console.log "InstrumentStore.onLoadAll()"
            Instrument.findAll()
                .then (instruments)->
                    InstrumentActions.loadAll.success (i.toView() for i in instruments)
                .catch (error)->
                    InstrumentActions.loadAll.error error

        onLoadAllSuccess: (instruments)->
            console.log "InstrumentStore.onLoadSuccess(#{JSON.stringify(instruments)})"
            @_instruments = instruments
            @trigger EVENT.CHANGE, @_instruments

        onLoadAllError: (error)->
            console.log "InstrumentStore.onLoadAllError(#{error})"
            @_error = error
            @trigger EVENT.ERROR, @_error
