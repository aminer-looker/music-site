#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular = require 'angular'
{EVENT} = require '../../../constants'

############################################################################################################

angular.module('work').factory 'WorkModelActions', (addModelStoreMixinActions)->
    return addModelStoreMixinActions {}

############################################################################################################

angular.module('work').factory 'WorkModelStore', (
    ModelStoreMixin, reflux, Work, WorkEditorStore, WorkModelActions
)->
    reflux.createStore
        init: ->
            WorkEditorStore.listen (event, id)=>
                return unless event is EVENT.SAVE
                return unless @_model? and id is @_model.id
                WorkModelActions.load id

        listenables: WorkModelActions

        mixins: [ModelStoreMixin]

        # ModelStoreMixin Overrides ####################################################

        _loadModel: (id)->
            Work.find id
                .then (work)->
                    Work.loadRelations work, ['composer', 'instrument', 'type']
