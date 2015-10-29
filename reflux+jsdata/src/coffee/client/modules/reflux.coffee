#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

_                 = require 'underscore'
angular           = require 'angular'
{EVENT}           = require '../../constants'
{PAGE_CACHE_SIZE} = require '../../constants'
{PAGE_SIZE}       = require '../../constants'
reflux            = require 'reflux'
w                 = require 'when'

# Angular ##################################################################################################

refluxModule = angular.module 'reflux', []

refluxModule.factory 'reflux', -> reflux

refluxModule.factory 'BaseActions', -> [ 'load', 'loadCount', 'loadPage', 'select', 'update' ]

# Default Store Methods ####################################################################################

reflux.StoreMethods.count = ->
    return @_count

reflux.StoreMethods.get = (id)->
    model = @Resource.get id
    return null unless model?
    return new @Editor model

reflux.StoreMethods.getPage = (filterString)->
    for page, index in @_pages
        if page.filterString is filterString
            @_pages.splice index, 1
            @_pages.push page

            return {
                total:  page.total
                offset: page.offset
                limit:  page.limit
                list:   (@get(model.id) for model in page.list)
            }

    return null

reflux.StoreMethods.onLoadCount = ->
    @Resource.count().then (count)->
        @_count = count
        @trigger EVENT.change.count, @_count

reflux.StoreMethods.onLoad = (id, options={})->
    @Resource.find id
        .then (model)=>
            if options.withRelations.length > 0
                return @Resource.loadRelations model, options.withRelations
            else
                return model
        .then (model)=>
            @trigger EVENT.change.model, model.id

reflux.StoreMethods.onLoadPage = (offset, limit, addFilters=null)->
    addFilters ?= (filters)-> return filters
    limit      ?= PAGE_SIZE
    offset     ?= 0
    page        = {}

    @Resource.count addFilters {}
        .then (count)=>
            page.filters = addFilters offset:offset, limit:limit
            page.filterString = JSON.stringify page.filters
            page.total = count
            @Resource.findAll page.filters
        .then (list)=>
            page.list = list
            page.offset = offset
            page.limit = limit

            @_pages ?= []
            @_pages.push page
            while @_pages.length > PAGE_CACHE_SIZE
                @_pages.shift()

            @trigger EVENT.change.page, JSON.stringify page.filters
        .catch (error)=>
            @trigger EVENT.error, error

reflux.StoreMethods.onSelect = (id)->
    @_id = id
    @trigger EVENT.select, @_id

reflux.StoreMethods.onUpdate = (modelData)->
    model = @Resource.get modelData.id
    if not model? then throw new Error 'cannot update a resource which has not been loaded'

    _.extend model, modelData

    model.DSSave().then =>
        @trigger EVENT.change.model, model.id
