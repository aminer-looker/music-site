#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

bodyParser = require 'body-parser'
constants = require '../constants'
clientSessions = require 'client-sessions'
express = require 'express'

############################################################################################################

exports.before = [
    bodyParser.json
        limit:      '1024kb'
    clientSessions
        cookieName: 'music-site-session'
        duration:   1000 * 60 * 60 * 24 * 7 * 2 # 2 weeks in ms
        secret:     '2liLtyVp3jIyPIOq'
]

exports.after = [
    express.static './static'
]
