#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

constants = require '../constants'
_         = require '../underscore'

############################################################################################################

exports.BaseController = BaseController = class BaseController

    constructor: ($scope, Resource)->
        if not $scope? then throw new Error '$scope is required'
        if not Resource? then throw new Error 'Resource is required'

        @Resource = Resource
        @$scope = $scope
        @error = null

    # Public Methods ###################################################################

    refresh: ->
        throw new Error 'subclasses must override refresh'

    reportError: (error)->
        errorText = error?.data?.stack
        errorText ?= error?.data
        errorText ?= error
        errorText ?= 'unknown error'

        console.error "Could not fetch for #{@constructor.name}: #{errorText}"
        @error = errorText

############################################################################################################

exports.DetailController = class DetailController extends BaseController

    constructor: ($scope, Resource, $location)->
        super $scope, Resource

        if not $location then throw new Error '$location is required'
        @$location = $location

        @id    = null
        @model = null

    getLocationId: ->
        match = /.*\/(.*)$/.exec @$location.path()
        return null unless match?

        id = parseInt match[1]
        return null unless _.isNumber id

        return id

    refresh: (options={})->
        options.withRelations ?= []

        if not @id? then @id = @getLocationId()
        return unless @id

        @Resource.find @id
            .then (model)=>
                @model = model

                if options.withRelations.length > 0
                    @Resource.loadRelations model, options.withRelations
            .catch (error)=>
                @reportError error

############################################################################################################

exports.PageableController = class PageableController extends BaseController

    constructor: ($scope, Resource)->
        super $scope, Resource

        @limit  = null
        @list   = null
        @offset = null
        @total  = null

    # Public Methods ###################################################################

    hasNextPage: ->
        return false unless @offset? and @total?
        return false if @offset + @limit >= @total
        return true

    hasPrevPage: ->
        return false unless @offset? and @limit?
        return false if @offset - @limit < 0
        return true

    nextPage: ->
        return unless @hasNextPage()
        @refresh @offset + @limit

    prevPage: ->
        return unless @hasPrevPage()
        @refresh @offset - @limit

    refresh: (offset=null, limit=null)->
        return unless @_isConfigured()

        offset ?= 0
        limit ?= constants.PAGE_SIZE

        # It would be *much* preferrable to do this as a single call, but js-data doesn't provide any way
        # to do that currently.  So, we first grab the current count, and then the requested page.
        @Resource.count @_appendFilterTo {}
            .then (count)=>
                @total = count
                @Resource.findAll @_appendFilterTo offset:offset, limit:limit
            .then (list)=>
                @list   = list
                @offset = offset
                @limit  = limit
            .catch (error)=>
                @reportError error

    # Overridable Methods ##############################################################

    # Subclasses may override this method to customize the filters on the list. If overridden, subclasses
    # MUST return the given options object.
    _appendFilterTo: (options)->
        return options

    # Subclasses may override this to prevent refreshing until it has been configured property (e.g., a
    # filter value has been provided).
    _isConfigured: ->
        return true
