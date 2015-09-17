#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular              = require 'angular'
templates            = require '../templates'
{DetailController}   = require '../base_controllers'
{PageableController} = require '../base_controllers'

############################################################################################################

composer = angular.module 'composer', ['schema']

# Controllers ##########################################################################

composer.controller 'ComposerListController', class ComposerListController extends PageableController

    constructor: ($scope, Composer)->
        super $scope, Composer
        @refresh()

composer.controller 'ComposerPageController', class ComposerPageController extends DetailController

    constructor: ($scope, Composer, $location)->
        super $scope, Composer, $location
        @refresh()

# Directives ###########################################################################

composer.directive 'composerListItem', ->
    restrict: 'C'
    scope:
        composer: '='
    template: templates['composer_list_item']
