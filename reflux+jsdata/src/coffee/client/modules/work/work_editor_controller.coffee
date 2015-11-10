#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular = require 'angular'

############################################################################################################

angular.module('work').controller 'WorkEditorController', (
    $scope, InstrumentActions, InstrumentListStore, TypeActions, TypeListStore, WorkEditorStore, WorkActions
)->
    InstrumentListStore.$listen $scope, (event, id)->
        $scope.instruments = InstrumentListStore.getAll()

    TypeListStore.$listen $scope, (event, id)->
        $scope.types = TypeListStore.getAll()

    WorkEditorStore.$listen $scope, (event, id)->
        $scope.work    = WorkEditorStore.get()
        $scope.isValid = WorkEditorStore.isValid()
        $scope.errors  = WorkEditorStore.getValidationErrors()

    $scope.save = ->
        WorkActions.save()

    $scope.cancel = ->
        WorkActions.cancel()

    InstrumentActions.loadAll()
    TypeActions.loadAll()
