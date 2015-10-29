#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

{EVENT}     = require '../constants'
{PAGE_SIZE} = require '../constants'
_           = require '../underscore'

############################################################################################################

exports.BaseController = BaseController = class BaseController

    constructor: ($scope, store, actions)->
        if not $scope? then throw new Error '$scope is required'
        if not store? then throw new Error 'store is required'
        if not actions? then throw new Error 'actions is required'

        @$scope  = $scope
        @actions = actions
        @error   = null
        @store   = store

        @store.listen (event, data)=> @_onStoreEvent event, data

    # Public Methods ###################################################################

    refresh: ->
        throw new Error 'subclasses must override refresh'

    onError: (event, error)->
        return unless event is 'error'

        errorText = error?.data?.stack
        errorText ?= error?.data
        errorText ?= error
        errorText ?= 'unknown error'

        console.error "Could not fetch for #{@constructor.name}: #{errorText}"
        @error = errorText

    onStoreChanged: (event, data)->
        throw new Error 'subclasses must override onStoreChanged'

    # Private Methods ##################################################################

    _onStoreEvent: (event, data)->
        if event is EVENT.change.count
            @onStoreCountChanged data
        else if event is EVENT.change.model
            @onStoreModelChanged data
        else if event is EVENT.change.page
            @onStorePageChanged page

############################################################################################################

exports.DetailController = class DetailController extends BaseController

    constructor: ($scope, store, $location, actions)->
        super $scope, store, actions

        @id    = null
        @model = null

        @updateSelectionFromLocation()

    # Public Methods ###################################################################

    updateSelectionFromLocation: ->
        match = /.*\/(.*)$/.exec @$location.path()
        return null unless match?

        id = parseInt match[1]
        return null unless _.isNumber id

        @actions.select id

    # BaseController Overrides #########################################################

    onStoreChanged: (event, id)->
        if event is EVENT.change.selection
            @id = id
            @actions.load @id
        else if event is EVENT.change.model and id is @id
            @model = @store.get @id

############################################################################################################

exports.PageableController = class PageableController extends BaseController

    constructor: ($scope, store, actions)->
        super $scope, store, actions

        @filterString = null
        @model        = null

    # Public Methods ###################################################################

    hasNextPage: ->
        return false unless @model?
        return false if @model.offset + @model.limit >= @model.total
        return true

    hasPrevPage: ->
        return false unless @model?
        return false if @model.offset - @model.limit < 0
        return true

    nextPage: ->
        return unless @hasNextPage()
        @refresh @model.offset + @model.limit

    prevPage: ->
        return unless @hasPrevPage()
        @refresh @model.offset - @model.limit

    refresh: (offset=null, limit=null)->
        return unless @_isConfigured()

        offset ?= 0
        limit ?= PAGE_SIZE
        @filterString = JSON.stringify @_appendFilterTo offset:offset, limit:limit

        @actions.loadPage offset, limit, (filter)=> return @_appendFilterTo(filter)

    # Property Methods #################################################################

    Object.defineProperties @prototype,
        list:
            get: ->
                return null unless @model
                @model.list

    # Overridable Methods ##############################################################

    # Subclasses may override this method to customize the filters on the list. If overridden, subclasses
    # MUST return the given options object.
    _appendFilterTo: (options)->
        return options

    # Subclasses may override this to prevent refreshing until it has been configured property (e.g., a
    # filter value has been provided).
    _isConfigured: ->
        return true

    # BaseController Overrides #########################################################

    onStoreChanged: (event, filterString)->
        return unless event is EVENT.change.page
        return unless @filterString is filterString
        @model = @store.getPage @filterString
