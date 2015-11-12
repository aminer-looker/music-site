#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

_            = require '../../../underscore'
angular      = require 'angular'
{EVENT}      = require '../../../constants'
{PAGE_SIZE}  = require '../../../constants'
ReadOnlyView = require '../../../read_only_view'

############################################################################################################

angular.module('mixins').factory 'addPageStoreMixinActions', (reflux)->
    return (actions)->
        return _.extend actions, reflux.createActions
            loadPage: { children: ['success', 'error'] }
            nextPage: {}
            prevPage: {}

############################################################################################################

angular.module('mixins').factory 'PageStoreMixin', (
    $q, ErrorActions, Page
)->
    # Public Methods ###################################################################

    get: ->
        return @_page

    getError: ->
        return @_error

    # Override Methods #################################################################

    _canLoad: ->
        # Users of this mixin may override this method to indicate they aren't ready to load a page yet.
        # Most commonly this will be because they haven't been configured with the criteria necessary to
        # know which objects to fetch (e.g., a list of child objects must have the parent's ID to proceed).
        # Subclasses should return `true` if they are ready to load objects or `false` otherwise.
        return true

    _loadTotal: ->
        # Users of this mixin must override this method to fetch the total number of objects across all
        # possible pages.  It should return a promise which resolves to that number.
        throw new Error 'PageStoreMixin requires _loadTotal'

    _loadPageList: (offset, limit)->
        # Users of this mixin must override this method to fetch the given range of objects. It should
        # return a promise which resolves to the requested list. The given objects should be in whatever
        # form is property to expose to the view layer.
        throw new Error 'PageStoreMixin requires _loadPageList'

    # Action Methods ###################################################################

    onLoadPage: (pageNumber)->
        if not @_actions.loadPage?.success?
            throw new Error 'PageStoreMixin requires _actions.loadPage.success'
        if not @_actions.loadPage?.error?
            throw new Error 'PageStoreMixin requires _actions.loadpage.error'

        return unless @_canLoad()

        pageNumber ?= 0
        total = null
        list = null

        $q.when(true)
            .then =>
                @_loadTotal()
            .then (count)=>
                total  = count
                offset = pageNumber * PAGE_SIZE
                limit  = PAGE_SIZE
                @_loadPageList offset, limit
            .then (list)=>
                totalPages = Math.ceil total / PAGE_SIZE
                @_actions.loadPage.success pageNumber, {totalPages:totalPages, list:list}
            .catch (error)=>
                @_actions.loadPage.error pageNumber, error

    onLoadPageError: (pageNumber, error)->
        @_error = error
        @trigger EVENT.ERROR, pageNumber
        ErrorActions.addError error

    onLoadPageSuccess: (pageNumber, data)->
        @_page = new Page pageNumber, data.totalPages, ReadOnlyView.convertObject data.list
        @trigger EVENT.CHANGE, pageNumber

    onNextPage: ->
        if not @_actions.loadPage? then throw new Error 'PageStoreMixin requires _actions.loadPage'

        if @_page?
            return unless @_page.hasNextPage()
            pageNumber = @_page.pageNumber + 1
        else
            pageNumber = 0

        @_actions.loadPage pageNumber

    onPrevPage: ->
        if not @_actions.loadPage? then throw new Error 'PageStoreMixin requires _actions.loadPage'

        if @_page?
            return unless @_page.hasPrevPage()
            pageNumber = @_page.pageNumber - 1
        else
            pageNumber = 0

        @_actions.loadPage pageNumber
