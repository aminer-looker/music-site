#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular = require 'angular'
reflux = require 'reflux'

############################################################################################################

refluxModule = angular.module 'reflux', []

refluxModule.factory 'reflux', -> return reflux
