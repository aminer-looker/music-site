#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular     = require 'angular'
_           = require '../../../underscore'
{EVENT}     = require '../../../constants'

############################################################################################################

angular.module('work').factory 'WorkPageActions', (addPageStoreMixinActions, reflux)->
    return addPageStoreMixinActions {}

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

        listenables: WorkPageActions

        mixins: [PageStoreMixin]

        # PageStoreMixin Methods #######################################################

        _canLoad: ->
            return @_composerId?

        _loadTotal: ->
            return Work.count composer_id:@_composerId

        _loadPageList: (offset, limit)->
            return Work.findAll composer_id:@_composerId, offset:offset, limit:limit
