#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

module.exports = (grunt)->

    grunt.loadTasks tasks for tasks in grunt.file.expand './node_modules/grunt-*/tasks'

    grunt.config.init

        rsync:
            server_source:
                options:
                    src: './src/coffee/*'
                    dest: './dist/'
                    exclude: ['client/']
                    recursive: true

        clean:
            dist: ['./dist']

        jade:
            all:
                options:
                    pretty: true
                files: [
                    expand: true
                    cwd:  './src/jade'
                    src:  '**/*.jade'
                    dest: './dist/static'
                    ext:  '.html'
                ]

        mochaTest:
            options:
                bail:     true
                color:    true
                reporter: 'dot'
                require: [
                    'coffee-script/register'
                    './test/test_helper.coffee'
                ]
                verbose: true
            src: ['./test/**/*.test.coffee', './test/**/*.test.js']

        sass:
            all:
                files:
                    './dist/static/main.css': ['./src/scss/main.scss']

        watch:
            client_source:
                files: ['./src/coffee/client/**/*.coffee']
                tasks: ['browserify']
            server_source:
                files: ['./src/coffee/**/*.coffee']
                tasks: ['rsync:server_source']
            jade:
                files: ['./src/**/*.jade']
                tasks: ['jade']
            sass:
                files: ['./src/**/*.scss']
                tasks: ['sass']
            test:
                files: ['./src/**/*.coffee', './test/**/*.coffee']
                tasks: ['test']

    grunt.registerTask 'default', ['test', 'build']

    grunt.registerTask 'browserify', "Bundle source files needed in the browser", ->
        grunt.file.mkdir './dist/static'

        done = this.async()
        options = cmd:'browserify', args:[
            '--extension=.coffee'
            '--external=axios'
            '--transform=coffeeify'
            '--outfile=./dist/static/client.js'
            './src/coffee/client/client.coffee'
        ]
        grunt.util.spawn options, (error)->
            console.log error if error?
            done()

    grunt.registerTask 'build', ['rsync', 'jade', 'sass', 'browserify']

    grunt.registerTask 'start', "Start the music-site server at port 8080", ->
      done = this.async()
      grunt.util.spawn cmd:'./scripts/start', opts:{stdio:'inherit'}, -> done()

    grunt.registerTask 'test', ['mochaTest']
