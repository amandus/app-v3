
var browserify = require('./browserify-task');
var compileForms = require('./compile-forms-task');
var upsertForms = require('./upsert-forms-task');
var seeds = require('./seeds-task');

module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

    browserify: {},

    concat: {
      libsjs: {
        // the files to concatenate
        src: ['vendor/jquery-1.9.1.min.js', 
              'vendor/lodash.compat.min.js', 
              'vendor/backbone.js', 
              'vendor/bootstrap/js/bootstrap.min.js', 
              'vendor/handlebars.runtime.js',
              'vendor/swag.js',
              'vendor/fastclick.js',
              'vendor/mobiscroll.custom-2.5.4.min.js',
              'vendor/jquery.scrollintoview.min.js',
              'vendor/overthrow.js',
              'vendor/leaflet/leaflet.js'],
        // the location of the resulting JS file
        dest: 'dist/js/libs.js'
      },
      libscss: {
        src: ['vendor/bootstrap/css/bootstrap.css',
              'vendor/*.css',
              'vendor/leaflet/leaflet.css'],
        dest: 'dist/css/libs.css'
      },
      css: {
          src: ['app/css/*.css'],
          dest: 'dist/css/app.css'
      }
    },

    uglify: {
      options: {
        banner: '/*! <%= pkg.name %> <%= grunt.template.today("yyyy-mm-dd") %> */\n'
      },
      dist: {
        src: 'dist/js/libs.js',
        dest: 'dist/js/libs.min.js'
      }
    },

    handlebars: {
      compile: {
        options: {
          namespace: "templates",
          wrapped: true,
          processName: function(filename) {
            var name = filename.substr('app/templates/'.length);    // cwd doesn't work
            name = name.substr(0, name.length-4);
            return name;
          }
      },
      files: {
        "dist/js/templates.js": ["app/templates/**/*.hbs"] }
      }
    },

    copy: {
      apphtml: {
        expand: true,
        cwd: 'app/html/',
        src: '*',
        dest: 'dist/'
      },
      appimages: {
        expand: true,
        cwd: 'app/img/',
        src: '*',
        dest: 'dist/img/',
      },
      libimages: {
        expand: true,
        cwd: 'vendor/bootstrap/img/',
        src: '*',
        dest: 'dist/img/',
      },
      leafletimages: {
        expand: true,
        cwd: 'vendor/leaflet/images/',
        src: '*',
        dest: 'dist/img/leaflet/',
      },
      cordova_www: {
        expand: true,
        cwd: 'dist/',
        src: '**',
        dest: 'cordova/www/'
      },  
      cordova_config: {
        expand: true,
        cwd: 'cordova/',
        src: 'config.xml',
        dest: 'cordova/www/',
      }
    },

    manifest: {
      generate: {
        options: {
          basePath: 'dist/',
          network: ['*'],
          preferOnline: true,
          verbose: true,
          timestamp: true
        },
        src: [
          '*.html',
          'js/*.js',
          'css/*.css',
          'img/**/*.png'
        ],
        dest: 'dist/manifest.appcache'
      }
    },

    shell: {
      deploy_demo: {
        command: [
          's3cmd sync --acl-public --guess-mime-type * s3://demo.mwater.co'
        ].join('&&'),
        options: {
          stdout: true,
          execOptions: {
            cwd: 'dist'
          }
        },
      },

      deploy_app: {
        command: [
          's3cmd sync --acl-public --guess-mime-type * s3://app.mwater.co',
          's3cmd put --acl-public --guess-mime-type ' +
          '--add-header "Cache-Control: no-cache, no-store, must-revalidate" ' +
          '--add-header "Pragma: no-cache" ' +
          '--add-header "Expires: 0" ' + 
          'manifest.appcache s3://app.mwater.co'
        ].join('&&'),
        options: {
          stdout: true,
          execOptions: {
              cwd: 'dist'
          }
        }
      },
    },

    watch: {
      scripts: {
        files: ['app/**/*.*'],
        tasks: ['default'],
      },
      forms: {
        files: ['forms/**/*.*'],
        tasks: ['compile-forms']
      }
    }

  });

  grunt.registerTask('browserify', 'Make single file output', browserify);
  grunt.registerTask('upsert-forms', 'Upsert forms to server', upsertForms);
  grunt.registerTask('compile-forms', 'Make forms into js', compileForms);
  grunt.registerTask('seeds', 'Seed database with some tables', seeds);

  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-contrib-handlebars');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-manifest');
  grunt.loadNpmTasks('grunt-shell');

  grunt.registerTask('cordova', ['copy:cordova_www', 'copy:cordova_config']);

  grunt.registerTask('copy-app', ['copy:apphtml', 'copy:appimages', 'copy:libimages', 'copy:leafletimages']);
  grunt.registerTask('default', ['browserify', 'seeds', 'concat', 'copy-app', 'handlebars', 'manifest']);

  grunt.registerTask('deploy_demo', ['default', 'shell:deploy_demo']);
  grunt.registerTask('deploy_app', ['default', 'shell:deploy_app']);
  grunt.registerTask('deploy', ['default', 'shell:deploy_app', 'shell:deploy_demo']);
};