#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

_       = require '../../../underscore'
angular = require 'angular'
{EVENT} = require '../../../constants'
ReadOnlyView = require '../../../read_only_view'

############################################################################################################

angular.module('mixins').factory 'addModelStoreMixinActions', (reflux)->
    return (actions)->
        _.extend actions, reflux.createActions
            load: { children: ['success', 'error'] }

############################################################################################################

angular.module('mixins').factory 'ModelStoreMixin', (
    ErrorActions, reflux
)->

    # Public Methods ###################################################################

    get: ->
        return @_model

    getError: ->
        return @_error

    # Overrideable Methods #############################################################

    _loadModel: (id)->
        # Users of this mixin must override this method to actually fetch the appropriate model.  The method
        # must return a promise for the model object itself.  This object must be safe to expose to the view
        # layer (i.e., immutable or a ReadOnlyView).
        throw new Error 'ModelStoreMixin requires you to provide _loadModel'

    # Action Methods ###################################################################

    onLoad: (id)->
        if not @_actions.load?.success? then throw new Error '_actions.load.success is required'
        if not @_actions.load?.error? then throw new Error '_actions.load.error is required'

        @_loadModel id
            .then (model)=>
                @_actions.load.success id, model
            .catch (error)=>
                @_actions.load.error id, error

    onLoadError: (id, error)->
        @_error = error
        @trigger EVENT.ERROR, id
        ErrorActions.addError error

    onLoadSuccess: (id, model)->
        @_model = ReadOnlyView.convertObject model
        @trigger EVENT.CHANGE, id
