#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular = require 'angular'
_       = require '../../../underscore'

############################################################################################################

angular.module('composer').factory 'ComposerListActions', (ListStoreMixinActions)->
    return _.extend {}, ListStoreMixinActions

############################################################################################################

angular.module('composer').factory 'ComposerListStore', (
    Composer, ComposerListActions, ListStoreMixin, reflux
)->
    reflux.createStore

        init: ->
            @_actions = ComposerListActions
            @listenToMany ComposerListActions

        mixins: [ListStoreMixin]

        # ListStoreMixin Methods #######################################################

        _loadTotal: ->
            Composer.count()

        _loadList: (offset, limit)->
            Composer.findAll offset:offset, limit:limit
