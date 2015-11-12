#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular = require 'angular'
_       = require '../../../underscore'
{EVENT} = require '../../../constants'

############################################################################################################

angular.module('composer').factory 'ComposerModelActions', (ModelStoreMixinActions)->
    return _.extend {}, ModelStoreMixinActions

############################################################################################################

angular.module('composer').factory 'ComposerModelStore', (
    Composer, ComposerModelActions, ModelStoreMixin, reflux
)->
    reflux.createStore
        init: ->
            @_actions = ComposerModelActions
            @listenToMany ComposerModelActions

        mixins: [ModelStoreMixin]

        # ModelStoreMixin Methods ######################################################

        _loadModel: (id)->
            Composer.find id
                .then (composer)->
                    return composer.toReadOnlyView()
