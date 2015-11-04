#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular = require 'angular'
{EVENT} = require '../../../constants'

############################################################################################################

angular.module('type').factory 'TypeListActions', (reflux)->
    reflux.createActions
        loadAll: { children: ['success', 'error'] }

# Stores ###################################################################################################

angular.module('type').factory 'TypeListStore', (Type, TypeListActions, reflux)->
    reflux.createStore
        init: ->
            @_types = []
            @listenToMany TypeListActions

        getAll: ->
            return @_types

        getError: ->
            return @_error

        onLoadAll: ->
            console.log "TypeListStore.onLoadAll()"
            Type.findAll()
                .then (types)->
                    TypeListActions.loadAll.success (i.toView() for i in types)
                .catch (error)->
                    TypeListActions.loadAll.error error

        onLoadAllSuccess: (types)->
            console.log "TypeListStore.onLoadSuccess(#{JSON.stringify(types)})"
            @_types = types
            @trigger EVENT.CHANGE

        onLoadAllError: (error)->
            console.log "TypeListStore.onLoadAllError(#{error})"
            @_error = error
            @trigger EVENT.ERROR
