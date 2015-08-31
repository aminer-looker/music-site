#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular = require 'angular'

############################################################################################################

composer = angular.module 'composer', ['schema']

# Controllers ##########################################################################

class ComposerListController

    constructor: ($scope, Composer)->
        @Composer = Composer
        @composers = null
        @error = null
        @$scope = $scope

        @refresh()

    refresh: ->
        @Composer.findAll()
            .then (composers)=>
                @composers = composers
            .catch (error)=>
                errorText = if error.data? then "#{error.data}" else "#{error}"
                console.error "Could not fetch composers: #{errorText}"
                @$scope.error = errorText

composer.controller 'ComposerListController', ComposerListController
