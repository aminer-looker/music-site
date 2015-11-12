#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular = require 'angular'
_       = require 'underscore'

############################################################################################################

workModule = angular.module 'work', [
    'composer'
    'error'
    'dialog'
    'instrument'
    'mixins'
    'page'
    'reflux'
    'schema'
    'type'
    'url'
]

require './work_editor_controller'
require './work_editor_directive'
require './work_editor_store'
require './work_model_controller'
require './work_model_store'
require './work_page_controller'
require './work_page_directive'
require './work_page_store'

workModule.factory 'WorkActions', (WorkEditorActions, WorkPageActions, WorkModelActions)->
    _.extend {}, WorkEditorActions, WorkPageActions, WorkModelActions
