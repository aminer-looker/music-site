#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular = require 'angular'
_       = require 'underscore'

############################################################################################################

composerModule = angular.module 'composer', [
    'mixins'
    'page'
    'reflux'
    'schema'
    'url'
]

require './composer_model_controller'
require './composer_model_store'
require './composer_page_controller'
require './composer_page_store'

composerModule.factory 'ComposerActions', (ComposerModelActions, ComposerPageActions)->
    _.extend {}, ComposerModelActions, ComposerPageActions
