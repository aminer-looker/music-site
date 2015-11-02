#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular = require 'angular'
{EVENT} = require '../../constants'

############################################################################################################

module = angular.module 'type', ['reflux', 'schema']

# Actions ##################################################################################################

module.factory 'TypeActions', (reflux)->
    reflux.createActions
        loadAll: { children: ['success', 'error'] }

# Stores ###################################################################################################

module.factory 'TypeStore', (Type, TypeActions, reflux)->
    reflux.createStore
        init: ->
            @_types = []
            @listenToMany TypeActions

        getAll: ->
            return @_types

        getError: ->
            return @_error

        onLoadAll: ->
            console.log "TypeStore.onLoadAll()"
            Type.findAll()
                .then (types)->
                    TypeActions.loadAll.success (i.toView() for i in types)
                .catch (error)->
                    TypeActions.loadAll.error error

        onLoadAllSuccess: (types)->
            console.log "TypeStore.onLoadSuccess(#{JSON.stringify(types)})"
            @_types = types
            @trigger EVENT.CHANGE, @_types

        onLoadAllError: (error)->
            console.log "TypeStore.onLoadAllError(#{error})"
            @_error = error
            @trigger EVENT.ERROR, @_error
