#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular              = require 'angular'
templates            = require '../templates'
{DetailController}   = require '../base_controllers'
{EVENT}              = require '../../constants'
{PageableController} = require '../base_controllers'

############################################################################################################

composer = angular.module 'composer', ['schema']

# Controllers ##########################################################################

composer.controller 'ComposerListController', class ComposerListController extends PageableController

    constructor: ($scope, ComposerStore, ComposerActions)->
        super $scope, ComposerStore, ComposerActions
        @refresh()

composer.controller 'ComposerPageController', class ComposerPageController extends DetailController

    constructor: ($scope, Composer, $location, ComposerActions)->
        super $scope, Composer, $location, ComposerActions
        @refresh()

# Directives ###########################################################################

composer.directive 'composerListItem', ->
    restrict: 'C'
    scope:
        composer: '='
    template: templates['composer_list_item']

# Factories ############################################################################

composer.factory 'ComposerActions', (reflux)->
    reflux.createActions [
        'loadCount'
        'loadPage'
    ]

composer.factory 'ComposerStore', (reflux, Composer, ComposerActions, ComposerEditor)->
    reflux.createStore
        init: ->
            @Resource = Composer
            @Editor = ComposerEditor

        listenables: ComposerActions

composer.factory 'ComposerEditor', (Composer)->

    class ComposerEditor

        constructor: (model)->
            @data   = {}
            @_model = model

        # Property Methods #########################################

        Object.defineProperties @prototype,
            detail_url:
                get: -> return @_model.getDetailUrl()
            first_name:
                get: -> return @data.first_name ?= @_model.first_name
                set: (text)-> return @data.first_name = text
            last_name:
                get: -> return @data.last_name ?= @_model.last_name
                set: (text)-> return @data.last_name = text
