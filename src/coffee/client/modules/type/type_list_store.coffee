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

angular.module('type').factory 'TypeListStore', (ErrorActions, Type, TypeListActions, reflux)->
    reflux.createStore
        init: ->
            @_types = []
            @listenToMany TypeListActions

        getAll: ->
            return @_types

        getError: ->
            return @_error

        onLoadAll: ->
            Type.findAll()
                .then (types)->
                    TypeListActions.loadAll.success (i.toReadOnlyView() for i in types)
                .catch (error)->
                    TypeListActions.loadAll.error error

        onLoadAllSuccess: (types)->
            @_types = types
            @trigger EVENT.CHANGE

        onLoadAllError: (error)->
            @_error = error
            @trigger EVENT.ERROR
            ErrorActions.addError error
