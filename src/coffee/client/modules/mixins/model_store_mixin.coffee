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
    init: ->
        allActions = _.gatherProperties @listenables

        if not allActions.load?.success?
            throw new Error 'ModelStoreMixin requires a load.success action'
        if not allActions.load?.error?
            throw new Error 'ModelStoreMixin requires a load.error action'

        @_fireLoadSuccess = allActions.load.success
        @_fireLoadError = allActions.load.error

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
        @_loadModel id
            .then (model)=>
                @_fireLoadSuccess id, model
            .catch (error)=>
                @_fireLoadError id, error

    onLoadError: (id, error)->
        @_error = error
        @trigger EVENT.ERROR, id
        ErrorActions.addError error

    onLoadSuccess: (id, model)->
        @_model = ReadOnlyView.convertObject model
        @trigger EVENT.CHANGE, id
