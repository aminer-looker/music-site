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
    'page'
    'reflux'
    'schema'
    'type'
]

require './work_editor_controller'
require './work_editor_directive'
require './work_editor_store'
require './work_list_controller'
require './work_list_directive'
require './work_list_store'
require './work_model_controller'
require './work_model_store'

workModule.factory 'WorkActions', (WorkEditorActions, WorkListActions, WorkModelActions)->
    _.extend {}, WorkEditorActions, WorkListActions, WorkModelActions
