#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular = require 'angular'
_       = require 'underscore'

############################################################################################################

composerModule = angular.module 'composer', ['mixins', 'page', 'reflux', 'schema']

require './composer_list_controller'
require './composer_list_item_directive'
require './composer_list_store'
require './composer_model_controller'
require './composer_model_store'

composerModule.factory 'ComposerActions', (ComposerListActions, ComposerModelActions)->
    _.extend {}, ComposerListActions, ComposerModelActions
