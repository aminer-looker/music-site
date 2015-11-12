#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

_            = require '../../../underscore'
angular      = require 'angular'
{EVENT}      = require '../../../constants'
ReadOnlyView = require '../../../read_only_view'

############################################################################################################

angular.module('mixins').factory 'addListStoreMixinActions', (reflux)->
    return (actions)->
        return _.extend actions, reflux.createActions
            loadAll: { children: ['success', 'error'] }

# Stores ###################################################################################################

angular.module('mixins').factory 'ListStoreMixin', (
    ErrorActions, reflux
)->
    # Public Methods ###################################################################

    getAll: ->
        return @_models

    getError: ->
        return @_error

    # Overrideable Methods #############################################################

    _loadAll: ->
        # Users of this mixin must override this method to return a promise of an array of models.  This
        # list should be all-inclusive within the context it is used (for a paged list, use the
        # PageStoreMixin instead).
        throw new Error 'ListStoreMixin requires a _loadAll method'

    # Actions Methods ##################################################################

    onLoadAll: ->
        if not @_actions?.loadAll?.success? then throw new Error '_actions.loadAll.success is required'
        if not @_actions?.loadAll?.error? then throw new Error '_actions.loadAll.error is required'

        @_loadAll()
            .then (models)=>
                @_actions.loadAll.success models
            .catch (error)=>
                @_actions.loadAll.error error

    onLoadAllError: (error)->
        @_error = error
        @trigger EVENT.ERROR
        ErrorActions.addError error

    onLoadAllSuccess: (models)->
        @_models = ReadOnlyView.convertObject models
        @trigger EVENT.CHANGE
