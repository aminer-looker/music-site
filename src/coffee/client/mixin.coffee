#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

constants = require '../constants'
_         = require 'underscore'

############################################################################################################

# Pageable decorates an object to be able to manage basic pages of objects. It will add a number of
# properties and methods related to the collection.  The instance must have an @Resource property defined
# which connects to the js-data Resource represented by the object.  If the instance has an `_onPageError`
# method, it will be called should fetching data fail. Otherwise, the returned promise will reject.
#
exports.Pageable = (instance)->

    if not instance.Resource
        throw new Error 'missing Resource on mixed instance'

    instance.limit  = null
    instance.list   = null
    instance.offset = null
    instance.total  = null

    instance.hasNextPage = ->
        return false unless @offset? and @total?
        return false if @offset + @limit >= @total
        return true

    instance.hasPrevPage = ->
        return false unless @offset? and @limit?
        return false if @offset - @limit < 0
        return true

    instance.nextPage = ->
        return unless @hasNextPage()
        @refresh @offset + @limit

    instance.prevPage = ->
        return unless @hasPrevPage()
        @refresh @offset - @limit

    instance.refresh = (offset=null, limit=null)->
        offset ?= @offset ?= 0
        limit ?= @limit ?= constants.PAGE_SIZE

        instance.Resource.count()
            .then (count)->
                instance.total = count

                instance.Resource.findAll offset:offset, limit:limit
            .then (list)->
                instance.list   = list
                instance.offset = offset
                instance.limit  = limit
            .catch (error)->
                if _.isFunction instance._onPageError
                    instance._onPageError error
                else
                    throw error
