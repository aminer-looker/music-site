#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular = require 'angular'

############################################################################################################

mixinsModule = angular.module 'mixins', []

require './editor_store_mixin'
require './list_store_mixin'
require './model_store_mixin'
require './page_store_mixin'
