#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular              = require 'angular'
_                    = require 'underscore'
{ERROR_DISPLAY_TIME} = require '../../../constants'
{EVENT}              = require '../../../constants'

############################################################################################################

angular.module('error').factory 'ErrorActions', (reflux)->
    reflux.createActions ['addError', 'removeError']

############################################################################################################

angular.module('error').factory 'ErrorStore', ($timeout, ErrorActions, reflux)->

    getNextErrorId = ->
        return _.uniqueId 'error-'

    reflux.createStore
        init: ->
            @_errors = []
            @listenToMany ErrorActions

        getMostRecent: ->
            return null unless @_errors.length > 0
            return @_errors[0]

        getAll: ->
            return @_errors[..]

        onAddError: (error, timeout=null)->
            timeout ?= ERROR_DISPLAY_TIME

            error.id = getNextErrorId()
            @_errors.unshift error

            @trigger EVENT.ADD, error.id
            @trigger EVENT.CHANGE, error.id

            if timeout > 0
                $timeout (-> ErrorActions.removeError error.id), timeout

        onRemoveError: (id)->
            @_errors = _.filter @_errors, (error)-> error.id isnt id

            @trigger EVENT.REMOVE, id
            @trigger EVENT.CHANGE, id
