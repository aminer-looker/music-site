require 'when/monitor/console'

chai = require 'chai'
chai.use require 'sinon-chai'

chai.config.includeStack = true

global._      = require 'underscore'
global.assert = chai.assert
global.expect = chai.expect
global.should = chai.should()
global.sinon  = require 'sinon'
global.util   = require 'util'
global.w      = require 'when'
