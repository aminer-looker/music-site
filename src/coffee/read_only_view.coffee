#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

_ = require 'underscore'

############################################################################################################

module.exports = class ReadOnlyView

    constructor: (source, fields...)->
        if fields.length is 0 then throw new Error 'at least one field must be provided'
        @_actions = {}
        @_cache = {}
        @_source = source

        fields = _.chain(fields).flatten().compact().value()

        propertyDefinitions = {}
        for field in fields
            propertyDefinitions[field] =
                get: @_makeGetter field
                set: @_makeSetter field

        Object.defineProperties this, propertyDefinitions

    # Public Methods ##################################################################

    setAction: (field, action)->
        if not @hasOwnProperty(field) then throw new Error "this view does not have a #{field} property"
        if not _.isFunction(action) then throw new Error "action must be a function"
        @_actions[field] = action

    setActions: (hash)->
        for field, action of hash
            @setAction field, action

    # Private Methods #################################################################

    _convertObject: (object)->
        result = null

        if not object?
            result = null
        else if _.isFunction object.toReadOnlyView
            result = object.toReadOnlyView()
        else if _.isArray object
            result = (@_convertObject(o) for o in object)
        else if _.isString(object) or _.isNumber(object)
            result = object
        else
            result = _.clone object

        return result

    _makeGetter: (field)->
        return ->
            if not @_cache.hasOwnProperty field
                @_cache[field] = @_convertObject @_source[field]

            return @_cache[field]

    _makeSetter: (field)->
        return (value)->
            actionFunc = @_actions[field]
            if not actionFunc then throw new Error "#{field} is read-only"
            commit = (value)=> @_cache[field] = value
            actionFunc this, field, value, commit
