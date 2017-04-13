// Usage:
// node menu_parse.js xcode.json

var yaml = require('js-yaml')
var fs = require('fs')

var fileName = process.argv[2]

if (!fileName) {
  console.log('Supply file path as first argument')
  process.exit(1)
}

try {
  var menuItems = JSON.parse(fs.readFileSync(fileName, 'utf8'))
  console.log('Loaded', fileName)

  var result = []
  menuItems.map((topLevelMenu) => {
    var topLevelMenuName = topLevelMenu[0]
    var innerItems = topLevelMenu[1]

    innerItems.forEach((item) => {
      result.push({
        name: item,
        menu: [topLevelMenuName, item]
      })
    })
  })

  console.log(yaml.safeDump(result))
} catch (e) {
  console.log(e)
  process.exit(1)
}
