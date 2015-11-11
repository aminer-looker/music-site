#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular = require 'angular'
{EVENT} = require '../../../constants'

############################################################################################################

angular.module('composer').factory 'ComposerModelActions', (reflux)->
    reflux.createActions
        load: { children: ['success', 'error'] }

############################################################################################################

angular.module('composer').factory 'ComposerModelStore', (
    Composer, ComposerModelActions, ErrorActions, reflux
)->
    reflux.createStore
        init: ->
            @_composer = null
            @_error = null
            @listenToMany ComposerModelActions

        get: ->
            return @_composer

        getError: ->
            return @_error

        onLoad: (id)->
            Composer.find id
                .then (composer)=>
                    ComposerModelActions.load.success id, composer.toReadOnlyView()
                .catch (error)->
                    ComposerModelActions.load.error id, error

        onLoadSuccess: (id, composer)->
            @_composer = composer
            @trigger EVENT.CHANGE, id

        onLoadError: (id, error)->
            @_error = error
            @trigger EVENT.ERROR, id
            ErrorActions.addError error
