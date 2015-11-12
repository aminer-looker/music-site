#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular = require 'angular'
_       = require '../../../underscore'

############################################################################################################

angular.module('composer').factory 'ComposerPageActions', (addPageStoreMixinActions)->
    return addPageStoreMixinActions {}

############################################################################################################

angular.module('composer').factory 'ComposerPageStore', (
    Composer, ComposerPageActions, PageStoreMixin, reflux
)->
    reflux.createStore

        init: ->
            @_actions = ComposerPageActions
            @listenToMany ComposerPageActions

        mixins: [PageStoreMixin]

        # PageStoreMixin Methods #######################################################

        _loadTotal: ->
            Composer.count()

        _loadPageList: (offset, limit)->
            Composer.findAll offset:offset, limit:limit
