#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular   = require 'angular'
templates = require '../../templates'

############################################################################################################

angular.module('work').directive 'workEditor', ->
    controller: 'WorkEditorController'
    controllerAs: 'controller'
    restrict: 'E'
    scope:
        id: '&'
    template: templates['work_editor']
