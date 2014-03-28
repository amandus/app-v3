# Extracts localizations from source code. Run with '../../' as parameters

fs = require 'fs'
glob = require 'glob'
path = require 'path'
localizationExtractor = require './localizationExtractor'

argv = require('minimist')(process.argv.slice(2))

if argv._.length < 1
  console.log "Parameters are <directory to scan> <localization file>?"
  return

dir = argv._[0]
datafile = argv._[1] || "localizations.json"
strs = []

# Find files and strings
files = glob.sync("**", { cwd: dir})
for file in files
  if not file
    continue

  full = path.resolve(dir, file)
  if fs.lstatSync(full).isFile()
    ext = path.extname(full)
    if ext == '.coffee'
      strs = strs.concat(localizationExtractor.findInCoffee(fs.readFileSync(full, 'utf-8')))
    if ext == '.js'
      strs = strs.concat(localizationExtractor.findInJs(fs.readFileSync(full, 'utf-8')))
    if ext == '.hbs'
      strs = strs.concat(localizationExtractor.findInHbs(fs.readFileSync(full, 'utf-8')))
    
# Read in data file
if fs.existsSync(datafile)
  localizations = JSON.parse(fs.readFileSync(datafile, 'utf-8'))
else 
  localizations = { locales: [{ code: "en", name: "English"}], strings: [] }

# Create map of english
map = {}
for loc in localizations.strings
  map[loc.en] = loc

for str in strs
  # Create item if doesn't exist
  if not map[str]
    string = { en: str }
    for loc in localizations.locales
      if loc.code != "en"
        string[loc.code] = ""
    localizations.strings.push string
    map[string.en] = string
  else
    # Just add missing languages
    for loc in localizations.locales
      if loc.code != "en" and not map[str][loc.code]?
        map[str][loc.code] = ""

fs.writeFileSync(datafile, JSON.stringify(localizations, null, 2), 'utf-8')
