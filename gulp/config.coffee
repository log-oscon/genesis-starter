{log, colors}     = require 'gulp-util'
hasFlag           = require 'has-flag'
findupNodeModules = require 'findup-node-modules'

host  = 'local.wordpress.dev'
src   = './src'
dest  = './public'
test  = './test'
debug = hasFlag 'debug'

if debug
  log colors.green "Building for development."
else
  log colors.green "Building for deployment."

module.exports =

  src: src

  dest: dest

  environment:
    debug: debug

  sass:
    src:      src + '/styles/*.{sass,scss}'
    dest:     './'
    settings: 
      sourceComments: do -> 'map' if debug
      imagePath:      'public/images'
      includePaths:   [
        findupNodeModules 'modularized-normalize-scss'
        findupNodeModules 'susy/sass'
      ]

  autoprefixer:
    browsers: [ 'last 2 versions' ]

  images:
    src: src + '/images/**'
    dest: dest + '/images'
    settings:
      svgoPlugins: [
        cleanupIDs: false
      ,
        removeUnknownsAndDefaults:
          SVGid: false
      ]

  svgSprite:
    mode:
      symbol: true

  phpunit:
    watch: '/**/*.php'
    src:   test + '/phpunit/**/*.test.php'

  jasmine:
    watch: dest + '/**/*.js'
    specs: dest + '/specs.js'

  jshint:
    src:      src + '/scripts/**/*.js'
    reporter: 'jshint-stylish'

  browserSync:
    proxy: host
    files: [
      '**/*.php'
      dest + '/**'
      '!' + dest + '/**/*.map' # Exclude sourcemaps
      '!' + test + '/**/*.php' # Exclude PHPUnit tests
    ]

  browserify:
    debug: debug,
    # Additional file extentions to make optional
    extensions: ['.coffee', '.cson', '.yaml', '.json', '.hbs', '.dust']
    # A separate bundle will be generated for each
    # bundle config in the list below
    bundleConfigs: [
      entries: src + '/scripts/app.coffee'
      dest: dest
      outputName: 'app.js'
      vendor: false
    ,
      dest: dest
      outputName: 'infrastructure.js'
      vendor: true
    ,
      entries: src + '/scripts/head.coffee'
      dest: dest
      outputName: 'head.js'
    ,
      entries: test + '/jasmine/**/*.spec.{js,coffee}'
      dest: dest
      outputName: 'specs.js'
    ]
