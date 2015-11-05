#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular   = require 'angular'
templates = require '../../templates'

############################################################################################################

angular.module('dialog').directive 'dialog', ($document)->
    controller: 'DialogController'
    controllerAs: 'controller'
    link: ($scope, $el, attrs)->
        $screen = $el.find('.screen').detach()
        $modalBox = $el.find('.modal-box').detach()

        $body = $document.find 'body'
        $body.append $screen
        $body.append $modalBox
    restrict: 'E'
    scope:
        name: '@'
    template: templates['dialog']
    transclude: true
