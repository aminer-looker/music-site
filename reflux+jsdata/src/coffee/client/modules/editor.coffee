#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular   = require 'angular'
templates = require '../templates'

############################################################################################################

editor = angular.module 'editor', []

# Controllers ##########################################################################

editor.controller 'EditorController', class EditorController

    constructor: (@$q)->
        @model = null
        @owner = null
        @_deferred = null

    beginEditing: (model)->
        @model = model
        @_deferred = @$q.defer()
        return @_deferred.promise

    save: ->
        return unless @model?
        model = @model
        @model = null

        model.save()
        @_deferred.resolve model
        @_deferred = null
        return model

    cancel: ->
        return unless @model?
        model = @model
        @model = null

        @_deferred.reject model
        @_deferred = null
        return model

    # Property Methods #############################################

    getEditing: ->
        return @_deferred?.promise

    Object.defineProperties @prototype,
        editing: { get:@::getEditing }

# Directives ###########################################################################

editor.directive 'editor', ->
    controller: 'EditorController'
    controllerAs: 'editor'
    link: ($scope, $el, attrs)->
        $scope.editor.owner = $scope.owner

        if $scope.owner?.registerEditorController?
            $scope.owner.registerEditorController $scope.editor
    restrict: 'E'
    scope:
        owner: '='
    template: templates['editor']
    transclude: true
