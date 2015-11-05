#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular   = require 'angular'
templates = require '../../templates'

############################################################################################################

angular.module('error').directive 'errorDisplay', ->
    controller: 'ErrorDisplayController'
    controllerAs: 'controller'
    restrict: 'E'
    scope: {}
    template: templates['error_display']
