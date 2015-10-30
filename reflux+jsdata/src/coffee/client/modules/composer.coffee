#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular              = require 'angular'
templates            = require '../templates'
_                    = require 'underscore'
{ERROR_DISPLAY_TIME} = require '../../constants'
{EVENT}              = require '../../constants'
{PAGE_SIZE}          = require '../../constants'

############################################################################################################

module = angular.module 'composer', ['page', 'reflux', 'schema']

# Actions ##################################################################################################

module.factory 'ComposerListActions', (reflux)->
    reflux.createActions
        loadPage: { children: ['success', 'error'] }
        nextPage: {}
        prevPage: {}

module.factory 'ComposerModelActions', (reflux)->
    reflux.createActions
        load: { children: ['success', 'error'] }

module.factory 'ComposerActions', (ComposerListActions, ComposerModelActions)->
    _.extend {}, ComposerModelActions, ComposerListActions

# Controllers ##############################################################################################

module.controller 'ComposerListController', ($scope, $timeout, ComposerActions, ComposerListStore)->
    ComposerListStore.listen (event, pageNumber, data)->
        $scope.$apply ->
            if event is EVENT.CHANGE
                $scope.composerPage = data
            else if event is EVENT.ERROR
                $scope.error = data
                $timeout (-> $scope.error = null), ERROR_DISPLAY_TIME

    $scope.nextPage = ->
        ComposerActions.nextPage()

    $scope.prevPage = ->
        ComposerActions.prevPage()

    ComposerActions.loadPage()

module.controller 'ComposerModelController', (
    $location, $scope, $timeout, ComposerActions, ComposerModelStore
)->
    ComposerModelStore.listen (event, id, data)->
        $scope.$apply ->
            if event is EVENT.CHANGE
                $scope.composer = data
            else if event is EVENT.ERROR
                $scope.error = data
                $timeout (-> $scope.error = null), ERROR_DISPLAY_TIME

    readLocationForId = ->
        match = /.*\/(.*)$/.exec $location.path()
        return null unless match?

        id = parseInt match[1]
        return null unless _.isNumber id

        return id

    ComposerActions.load readLocationForId()

# Directives ###############################################################################################

module.directive 'composerListItem', ->
    restrict: 'C'
    scope:
        composer: '='
    template: templates['composer_list_item']

# Stores ###################################################################################################

module.factory 'ComposerListStore', ($q, Composer, ComposerListActions, Page, reflux)->
    reflux.createStore
        init: ->
            @_page = null
            @listenToMany ComposerListActions

        get: ->
            return @_page

        onLoadPage: (pageNumber)->
            pageNumber ?= 0
            total = null
            list = null

            $q.when(true)
                .then ->
                    Composer.count()
                .then (count)->
                    total  = count
                    offset = pageNumber * PAGE_SIZE
                    limit  = PAGE_SIZE
                    Composer.findAll offset:offset, limit:limit
                .then (composers)->
                    list = (c.toView() for c in composers)
                    totalPages = Math.ceil total / PAGE_SIZE
                    ComposerListActions.loadPage.success pageNumber, totalPages, list
                .catch (error)->
                    ComposerListActions.loadPage.error pageNumber, error

        onLoadPageError: (pageNumber, error)->
            @trigger EVENT.ERROR, pageNumber, error

        onLoadPageSuccess: (pageNumber, totalPages, list)->
            @_page = new Page pageNumber, totalPages, list
            @trigger EVENT.CHANGE, pageNumber, @_page

        onNextPage: ->
            if @_page?
                return unless @_page.hasNextPage()
                pageNumber = @_page.pageNumber + 1
            else
                pageNumber = 0

            ComposerListActions.loadPage pageNumber

        onPrevPage: ->
            if @_page?
                return unless @_page.hasPrevPage()
                pageNumber = @_page.pageNumber - 1
            else
                pageNumber = 0

            ComposerListActions.loadPage pageNumber

module.factory 'ComposerModelStore', (Composer, ComposerModelActions, reflux)->
    reflux.createStore
        init: ->
            @_composer = null
            @listenToMany ComposerModelActions

        get: ->
            return @_composer

        onLoad: (id)->
            Composer.find id
                .then (composer)=>
                    ComposerModelActions.load.success id, composer.toView()
                .catch (error)->
                    ComposerModelActions.load.error id, error

        onLoadSuccess: (id, composer)->
            @_composer = composer
            @trigger EVENT.CHANGE, id, composer

        onLoadError: (id, error)->
            @trigger EVENT.ERROR, id, error
