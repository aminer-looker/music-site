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

module.factory 'ComposerModelActions', (reflux)->
    reflux.createActions
        'load':
            children: ['success', 'error']

module.factory 'ComposerPageActions', (reflux)->
    reflux.createActions
        loadPage: { children: ['success', 'error'] }
        nextPage: {}
        prevPage: {}

module.factory 'ComposerActions', (ComposerModelActions, ComposerPageActions)->
    _.extend {}, ComposerModelActions, ComposerPageActions

# Controllers ##############################################################################################

module.controller 'ComposerListController', ($scope, $timeout, ComposerActions, ComposerPageStore)->
    ComposerPageStore.listen (event, pageNumber, data)->
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

# Directives ###############################################################################################

module.directive 'composerListItem', ->
    restrict: 'C'
    scope:
        composer: '='
    template: templates['composer_list_item']

# Stores ###################################################################################################

module.factory 'ComposerStore', (Composer, ComposerModelActions, reflux)->
    reflux.createStore
        init: ->
            @_composer = null
            @listenToMany ComposerModelActions

        get: ->
            return @_composer

        onLoad: (id)->
            Composer.find id
                .then (composer)=>
                    @_composer = composer.toJSON()
                    @trigger EVENT.CHANGE, id, @_composer
                .catch (error)->
                    @trigger EVENT.ERROR, id, error

module.factory 'ComposerPageStore', ($q, Composer, ComposerPageActions, Page, reflux)->
    reflux.createStore
        init: ->
            @_page = null
            @listenToMany ComposerPageActions

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
                    list = (c.toJSON() for c in composers)
                    totalPages = Math.ceil total / PAGE_SIZE
                    ComposerPageActions.loadPage.success pageNumber, totalPages, list
                .catch (error)->
                    ComposerPageActions.loadPage.error pageNumber, error

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

            ComposerPageActions.loadPage pageNumber

        onPrevPage: ->
            if @_page?
                return unless @_page.hasPrevPage()
                pageNumber = @_page.pageNumber - 1
            else
                pageNumber = 0

            ComposerPageActions.loadPage pageNumber
