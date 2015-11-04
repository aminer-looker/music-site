#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular = require 'angular'
_       = require 'underscore'

############################################################################################################

dialogModule = angular.module 'dialog', ['reflux', 'schema']

require './dialog_controller'
require './dialog_directive'
require './dialog_store'
