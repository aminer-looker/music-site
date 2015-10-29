#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular   = require 'angular'
templates = require '../templates'

############################################################################################################

dialog = angular.module 'dialog', []

# Controllers ##########################################################################

dialog.controller 'DialogController', class DialogController

    constructor: ->
        @owner = null
        @title = ''
        @_visible = false

    close: ->
        if @owner?.canCloseDialog?
            return unless @owner.canCloseDialog this
        @_visible = false

    open: ->
        @_visible = true

    # Property Methods #############################################

    Object.defineProperties @prototype,
        visible:
            get: -> return @_visible
            set: (visible)-> if visible then @open() else @close()

# Directives ###########################################################################

dialog.directive 'dialog', ($document)->
    controller: 'DialogController'
    controllerAs: 'controller'
    link: ($scope, $el, attrs)->
        $scope.controller.owner = $scope.owner

        if $scope.owner?.registerDialogController?
            $scope.owner.registerDialogController $scope.controller

        $screen = $el.find('.screen').detach()
        $modalBox = $el.find('.modal-box').detach()

        $body = $document.find 'body'
        $body.append $screen
        $body.append $modalBox
    restrict: 'E'
    scope:
        owner: '='
    template: templates['dialog']
    transclude: true
