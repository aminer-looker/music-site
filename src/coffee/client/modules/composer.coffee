#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular   = require 'angular'
templates = require '../templates'
_         = require 'underscore'

############################################################################################################

composer = angular.module 'composer', ['schema']

# Controllers ##########################################################################

class ComposerBaseController

    constructor: ($scope, Composer)->
        @Composer = Composer
        @error = null

        @refresh()

    _reportError: (error)->
        errorText = "#{error?.data?.stack}"
        errorText ?= "#{error?.data}"
        errorText ?= "#{error}"

        console.error "Could not fetch for #{@constructor.name}: #{errorText}"
        @error = errorText

class ComposerListController extends ComposerBaseController

    constructor: ($scope, Composer)->
        @composers = null
        super

    refresh: ->
        @Composer.findAll()
            .catch (error)=> @_reportError error
            .then (composers)=>
                @composers = composers

composer.controller 'ComposerListController', ComposerListController

class ComposerPageController extends ComposerBaseController

    URL_PATTERN = /\/composers\/(.*)$/

    constructor: ($scope, Composer, $location)->
        @id = @_extractId $location
        @composer = null
        super

    refresh: ->
        return unless @id

        @Composer.find @id
            .catch (error)=> @_reportError error
            .then (composer)=>
                @composer = composer

    _extractId: ($location)->
        match = URL_PATTERN.exec $location.path()
        return match[1] if match? and _.isNumber parseInt match[1]
        return null

composer.controller 'ComposerPageController', ComposerPageController

# Directives ###########################################################################

composer.directive 'composerListItem', ->
    return {
        restrict: 'C'
        scope:
            composer: '='
        template: templates['composer_list_item']
    }
