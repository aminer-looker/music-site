#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular   = require 'angular'
templates = require '../../templates'

############################################################################################################

angular.module('work').directive 'workPage', ->
    controller: 'WorkPageController'
    controllerAs: 'controller'
    restrict: 'E'
    scope: {}
    template: templates['work_page']
