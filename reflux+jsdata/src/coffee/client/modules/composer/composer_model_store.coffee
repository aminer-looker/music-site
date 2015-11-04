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

angular.module('composer').factory 'ComposerModelStore', (Composer, ComposerModelActions, reflux)->
    reflux.createStore
        init: ->
            @_composer = null
            @listenToMany ComposerModelActions

        get: ->
            return @_composer

        onLoad: (id)->
            Composer.find id
                .then (composer)=>
                    ComposerModelActions.load.success id, composer.toView()
                .catch (error)->
                    ComposerModelActions.load.error id, error

        onLoadSuccess: (id, composer)->
            @_composer = composer
            @trigger EVENT.CHANGE, id, composer

        onLoadError: (id, error)->
            @trigger EVENT.ERROR, id, error
