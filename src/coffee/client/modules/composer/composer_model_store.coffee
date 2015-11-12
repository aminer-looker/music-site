#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular = require 'angular'
{EVENT} = require '../../../constants'

############################################################################################################

angular.module('composer').factory 'ComposerModelActions', (addModelStoreMixinActions)->
    return addModelStoreMixinActions {}

############################################################################################################

angular.module('composer').factory 'ComposerModelStore', (
    Composer, ComposerModelActions, ModelStoreMixin, reflux
)->
    reflux.createStore
        init: ->
            @_actions = ComposerModelActions
            @listenToMany @_actions

        mixins: [ModelStoreMixin]

        # ModelStoreMixin Methods ######################################################

        _loadModel: (id)->
            return Composer.find id
