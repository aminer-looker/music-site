#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular     = require 'angular'
{EVENT}     = require '../../../constants'
{PAGE_SIZE} = require '../../../constants'

############################################################################################################

angular.module('composer').factory 'ComposerListActions', (reflux)->
    reflux.createActions
        loadPage: { children: ['success', 'error'] }
        nextPage: {}
        prevPage: {}

############################################################################################################

angular.module('composer').factory 'ComposerListStore', (
    $q, Composer, ComposerListActions, Page, reflux
)->
    reflux.createStore
        init: ->
            @_page = null
            @listenToMany ComposerListActions

        get: ->
            return @_page

        onLoadPage: (pageNumber)->
            pageNumber ?= 0
            total = null
            list = null

            $q.when(true)
                .then ->
                    Composer.count()
                .then (count)->
                    total  = count
                    offset = pageNumber * PAGE_SIZE
                    limit  = PAGE_SIZE
                    Composer.findAll offset:offset, limit:limit
                .then (composers)->
                    list = (c.toView() for c in composers)
                    totalPages = Math.ceil total / PAGE_SIZE
                    ComposerListActions.loadPage.success pageNumber, totalPages, list
                .catch (error)->
                    ComposerListActions.loadPage.error pageNumber, error

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

            ComposerListActions.loadPage pageNumber

        onPrevPage: ->
            if @_page?
                return unless @_page.hasPrevPage()
                pageNumber = @_page.pageNumber - 1
            else
                pageNumber = 0

            ComposerListActions.loadPage pageNumber
