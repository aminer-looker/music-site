#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular = require 'angular'
{EVENT} = require '../../../constants'

############################################################################################################

angular.module('work').factory 'WorkModelActions', (reflux)->
    reflux.createActions
        load: { children: ['success', 'error'] }

############################################################################################################

angular.module('work').factory 'WorkModelStore', (Work, WorkEditorStore, WorkModelActions, reflux)->
    reflux.createStore
        init: ->
            WorkEditorStore.listen (event, id, data)=>
                console.log "WorkModelStore.WorkEditorStore.listen(#{event}, #{id}, #{JSON.stringify(data)})"
                return unless event is EVENT.SAVE
                return unless @_work? and id is @_work.id
                WorkModelActions.load id

            @_work = null
            @listenToMany WorkModelActions

        get: ->
            return @_work

        onLoad: (id)->
            console.log "WorkModelStore.onLoad(#{id})"
            relations = ['composer', 'instrument', 'type']

            Work.find id
                .then (work)->
                    Work.loadRelations work, relations
                .then (work)->
                    WorkModelActions.load.success id, work.toView relations:relations
                .catch (error)->
                    WorkModelActions.load.error id, error

        onLoadSuccess: (id, work)->
            console.log "WorkModelStore.onLoadSuccess(#{id}, #{JSON.stringify(work)})"
            @_work = work
            @trigger EVENT.CHANGE, id, work

        onLoadError: (id, error)->
            console.log "WorkModelStore.onLoadError(#{id}, #{JSON.stringify(error)})"
            @trigger EVENT.ERROR, id, error
