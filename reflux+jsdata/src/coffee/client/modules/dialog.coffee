#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular        = require 'angular'
templates      = require '../templates'
_              = require 'underscore'
{DIALOG_STATE} = require '../../constants'
{EVENT}        = require '../../constants'

############################################################################################################

dialog = angular.module 'dialog', []

# Actions ##############################################################################

dialog.factory 'DialogActions', (reflux)->
    reflux.createActions ['open', 'close', 'register', 'setTitle']

# Controllers ##########################################################################

dialog.controller 'DialogController', ($scope, DialogActions, DialogStore)->
    DialogStore.listen (event, name)->
        return unless event is EVENT.CHANGE
        return unless name is $scope.name

        $scope.$apply ->
            data = DialogStore.get name
            _.extend $scope, data
            $scope.visible = data.state is DIALOG_STATE.OPEN

    $scope.name ?= DialogStore.getUniqueName()
    $scope.state ?= DIALOG_STATE.CLOSED
    $scope.title ?= ''

    $scope.close = ->
        DialogActions.close $scope.name

    DialogActions.register $scope.name, $scope.state, $scope.title

# Directives ###########################################################################

dialog.directive 'dialog', ($document, DialogActions, DialogStore)->
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
        state: '@'
        title: '@'
    template: templates['dialog']
    transclude: true

# Stores ###############################################################################

dialog.factory 'DialogStore', (DialogActions, reflux)->
    reflux.createStore
        init: ->
            @_nextId = 0
            @_data = {}
            @listenToMany DialogActions

        get: (name)->
            @_data[name] ?= state:DIALOG_STATE.CLOSED, title:''
            return _.extend {}, @_data[name]

        getUniqueName: ->
            while true
                name = "dialog-#{@_nextId}"
                return name unless @_data[name]?
                @_nextId += 1

        onRegister: (name, state, title)->
            if not state in [DIALOG_STATE.OPEN, DIALOG_STATE.CLOSED]
                throw new Error "invalid dialog state: \"#{state}\""
            console.log "DialogStore.onRegister(#{name}, #{state}, #{title})"

            @_data[name] = state:state, title:(title or '')
            @trigger EVENT.CHANGE, name

        onOpen: (name)->
            console.log "DialogStore.onOpen(#{name})"
            @_data[name] ?= state:DIALOG_STATE.OPEN, title:''
            @_data[name].state = DIALOG_STATE.OPEN
            @trigger EVENT.CHANGE, name

        onClose: (name)->
            console.log "DialogStore.onClose(#{name})"
            @_data[name] ?= state:DIALOG_STATE.CLOSED, title:''
            @_data[name].state = DIALOG_STATE.CLOSED
            @trigger EVENT.CHANGE, name

        onSetTitle: (name, title)->
            console.log "DialogStore.onSetTitle(#{name}, #{title})"
            @_data[name] ?= state:DIALOG_STATE.CLOSED, title:''
            @_data[name].title = (title or '')
            @trigger EVENT.CHANGE, name
