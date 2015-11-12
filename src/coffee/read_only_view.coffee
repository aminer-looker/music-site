#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

_ = require './underscore'

############################################################################################################

module.exports = class ReadOnlyView

    # Creates a new ReadOnlyView which proxies a given list of fields from the given source object.  The
    # source object can be any object at all.  The remaining arguments should either be strings or arrays
    # of strings which correspond to fields on the source object.
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

    # Class Methods ###################################################################

    # Convert an arbitrary object into a ReadOnlyView, if possible.  Different kinds of objects are handled
    # different ways:
    #
    #   * For Strings, Numbers, Booleans, ReadOnlyViews, and nulls the same value will be returned
    #   * For Functions, the function itself will be returned
    #   * For an object with a `toReadOnlyView` method, the result of calling that method will be returned
    #   * For an array, a new array will be returned with each member converted
    #   * For anything else, a shallow clone will be returned
    #
    @convertObject: (object)->
        result = null

        if not object?
            result = null
        else if object.constructor?.name? is 'ReadOnlyView'
            result = object
        else if _.isFunction object
            result = object
        else if _.isString(object) or _.isNumber(object) or _.isBoolean(object)
            result = object
        else if _.isFunction object.toReadOnlyView
            result = object.toReadOnlyView()
        else if _.isArray object
            result = (ReadOnlyView.convertObject(o) for o in object)
        else
            result = _.clone object

        return result

    # Public Methods ##################################################################

    # Register an action to be invoked when a given field is changed.  Instead of throwing an exception,
    # the setter for that field will fire the given action with the following parameters:
    #
    #  * this read-only view object
    #  * the name of the field which changed
    #  * the proposed value of the field
    #  * a `commit` function which may be called with an accepted value
    #
    # If the `commit` function is called, the given value will replace the one currently in this view's
    # cache.  It
    # *will not* update the underlying source object.  Future references to the field will return the new
    # value. To update the source object, you'll need to update the source object directly.
    setAction: (field, action)->
        if not @hasOwnProperty(field) then throw new Error "this view does not have a #{field} property"
        if not _.isFunction(action) then throw new Error "action must be a function"
        @_actions[field] = action

    # Register multiple actions to be invoked when various fields are changed.  See the documentation for
    # the `setAction` method for full details.
    setActions: (hash)->
        for field, action of hash
            @setAction field, action

    # Private Methods #################################################################

    _makeGetter: (field)->
        return ->
            if not @_cache.hasOwnProperty field
                @_cache[field] = ReadOnlyView.convertObject @_source[field]

            return @_cache[field]

    _makeSetter: (field)->
        return (value)->
            actionFunc = @_actions[field]
            if not actionFunc then throw new Error "#{field} is read-only"
            commit = (value)=> @_cache[field] = value
            actionFunc this, field, value, commit
