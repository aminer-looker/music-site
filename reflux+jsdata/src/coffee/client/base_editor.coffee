#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

############################################################################################################

module.exports = class BaseEditor

    constructor: (store, model)->
        if not store? then throw new Error 'store is required'
        if not model? then throw new Error 'model is required'

        @data   = {}
        @store  = store
        @_model = model

    # Public Methods ###########################################

    cancel: ->
        # do nothing

    save: ->
        @store.update @data

    # Property Methods #########################################

    Object.defineProperties @prototype,
        # This an example of how to set up a simple `string` property. The goal is that reads will either
        # return the value from `@data` if there is one, or the value from the `@_model` if not. Any changes
        # will go directly to the `@data` object after being validated / transformed. These changes will
        # only be sent back to the store when the `save` method is called.
        #
        # exampleProperty:
        #     get: -> @data.example_property ?= @_model.example_property
        #     set: (text)-> @data.example_property = text
