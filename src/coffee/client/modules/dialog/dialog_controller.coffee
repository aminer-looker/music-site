#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular        = require 'angular'
_              = require 'underscore'
{DIALOG_STATE} = require '../../../constants'
{EVENT}        = require '../../../constants'

############################################################################################################

angular.module('dialog').controller 'DialogController', ($scope, DialogActions, DialogStore)->

    DialogStore.$listen $scope, (event, name)->
        return unless event is EVENT.CHANGE
        return unless name is $scope.name

        data = DialogStore.get name
        _.extend $scope, data
        $scope.visible = data.state is DIALOG_STATE.OPEN

    $scope.name ?= DialogStore.getUniqueName()

    $scope.close = ->
        DialogActions.close $scope.name

    DialogActions.register $scope.name, $scope.state, $scope.title
