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
            ComposerModelStore.listen (event, id, data)=>
                if event is EVENT.CHANGE and id isnt @_composerId
                    @_composerId = id
                    WorkListActions.loadPage()

            @_composerId = null
            @_page = null
            @listenToMany WorkListActions

        get: ->
            return @_page

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
                    WorkListActions.loadPage.success pageNumber, totalPages, list
                .catch (error)->
                    WorkListActions.loadPage.error pageNumber, error

        onLoadPageError: (pageNumber, error)->
            @trigger EVENT.ERROR, pageNumber, error

        onLoadPageSuccess: (pageNumber, totalPages, list)->
            @_page = new Page pageNumber, totalPages, list
            @trigger EVENT.CHANGE, pageNumber, @_page

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
