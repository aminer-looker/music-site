#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular   = require 'angular'
templates = require '../../templates'

############################################################################################################

angular.module('composer').directive 'composerListItem', ->
    restrict: 'C'
    scope:
        composer: '='
    template: templates['composer_list_item']
