#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular     = require 'angular'
_           = require '../../../underscore'
{EVENT}     = require '../../../constants'

############################################################################################################

angular.module('work').factory 'WorkPageActions', (PageStoreMixinActions, reflux)->
    return _.extend {}, PageStoreMixinActions

############################################################################################################

angular.module('work').factory 'WorkPageStore', (
    ComposerModelStore, PageStoreMixin, reflux, Work, WorkPageActions
)->
    reflux.createStore
        init: ->
            ComposerModelStore.listen (event, id)=>
                if event is EVENT.CHANGE and id isnt @_composerId
                    @_composerId = id
                    WorkPageActions.loadPage()

            @_composerId = null

            @_actions = WorkPageActions
            @listenToMany @_actions

        mixins: [PageStoreMixin]

        # PageStoreMixin Methods #######################################################

        _canLoad: ->
            @_composerId?

        _loadTotal: ->
            Work.count composer_id:@_composerId

        _loadPageList: (offset, limit)->
            Work.findAll composer_id:@_composerId, offset:offset, limit:limit
                .then (models)->
                    return (m.toReadOnlyView() for m in models)
