#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular     = require 'angular'
_           = require '../../../underscore'
{EVENT}     = require '../../../constants'
{PAGE_SIZE} = require '../../../constants'

############################################################################################################

angular.module('work').factory 'WorkListActions', (ListStoreMixinActions, reflux)->
    return _.extend {}, ListStoreMixinActions

############################################################################################################

angular.module('work').factory 'WorkListStore', (
    ComposerModelStore, ListStoreMixin, reflux, Work, WorkListActions
)->
    reflux.createStore
        init: ->
            ComposerModelStore.listen (event, id)=>
                if event is EVENT.CHANGE and id isnt @_composerId
                    @_composerId = id
                    WorkListActions.loadPage()

            @_composerId = null

            @_actions = WorkListActions
            @listenToMany @_actions

        mixins: [ListStoreMixin]

        # ListStoreMixin Methods #######################################################

        _canLoad: ->
            @_composerId?

        _loadTotal: ->
            Work.count composer_id:@_composerId

        _loadList: (offset, limit)->
            Work.findAll composer_id:@_composerId, offset:offset, limit:limit
                .then (models)->
                    return (m.toReadOnlyView() for m in models)
