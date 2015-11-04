#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular     = require 'angular'
{EVENT}     = require '../../../constants'
{PAGE_SIZE} = require '../../../constants'

############################################################################################################

angular.module('work').factory 'WorkListActions', (reflux)->
    reflux.createActions
        loadPage: { children: ['success', 'error'] }
        nextPage: {}
        prevPage: {}

############################################################################################################

angular.module('work').factory 'WorkListStore', (
    $q, ComposerModelStore, Page, reflux, Work, WorkListActions
)->
    reflux.createStore
        init: ->
            ComposerModelStore.listen (event, id)=>
                if event is EVENT.CHANGE and id isnt @_composerId
                    @_composerId = id
                    WorkListActions.loadPage()

            @_composerId = null
            @_page = null
            @listenToMany WorkListActions

        get: ->
            return @_page

        getError: ->
            return @_error

        onLoadPage: (pageNumber)->
            return unless @_composerId?

            pageNumber ?= 0
            total = null
            list = null

            $q.when(true)
                .then =>
                    Work.count composer_id:@_composerId
                .then (count)=>
                    total  = count
                    offset = pageNumber * PAGE_SIZE
                    limit  = PAGE_SIZE
                    Work.findAll composer_id:@_composerId, offset:offset, limit:limit
                .then (works)->
                    list = (w.toView() for w in works)
                    totalPages = Math.ceil total / PAGE_SIZE
                    WorkListActions.loadPage.success pageNumber, {totalPages:totalPages, list:list}
                .catch (error)->
                    WorkListActions.loadPage.error pageNumber, error

        onLoadPageError: (pageNumber, error)->
            @_error = error
            @trigger EVENT.ERROR, pageNumber

        onLoadPageSuccess: (pageNumber, data)->
            @_page = new Page pageNumber, data.totalPages, data.list
            @trigger EVENT.CHANGE, pageNumber

        onNextPage: ->
            if @_page?
                return unless @_page.hasNextPage()
                pageNumber = @_page.pageNumber + 1
            else
                pageNumber = 0

            WorkListActions.loadPage pageNumber

        onPrevPage: ->
            if @_page?
                return unless @_page.hasPrevPage()
                pageNumber = @_page.pageNumber - 1
            else
                pageNumber = 0

            WorkListActions.loadPage pageNumber
