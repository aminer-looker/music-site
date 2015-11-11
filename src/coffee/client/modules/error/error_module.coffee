#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular = require 'angular'

############################################################################################################

errorModule = angular.module 'error', ['reflux']

require './error_display_controller'
require './error_display_directive'
require './error_store'
