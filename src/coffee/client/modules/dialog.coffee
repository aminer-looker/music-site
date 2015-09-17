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
        @title = ''
        @visible = false

    close: ->
        @visible = false

# Directives ###########################################################################

dialog.directive 'dialog', ($document)->
    controller: 'DialogController'
    controllerAs: 'controller'
    link: ($scope, $el, attrs)->
        $scope.controller.title = attrs.title
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
