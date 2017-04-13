// Usage:
// node menu_parse.js xcode.menudump

var yaml = require('js-yaml')
var fs = require('fs')

var fileName = process.argv[2]

if (!fileName) {
  console.log('Supply file path as first argument')
  process.exit(1)
}

try {
  var rawMenuDump = fs.readFileSync(fileName, 'utf8')
  var cleanMenuDump = rawMenuDump
      .replace(/\{/g, '[')
      .replace(/\}/g, ']')
      .replace(/\[?missing value\]?,?/g, '')
  var menuItems = JSON.parse(cleanMenuDump)

  var result = []
  menuItems.map((topLevelMenu) => {
    var topLevelMenuName = topLevelMenu[0]
    var innerItems = topLevelMenu[1]

    innerItems.forEach((item) => {
      switch (item.length) {
      case 1:
        result.push({
          name: topLevelMenuName + ' - ' + item[0],
          menu: [topLevelMenuName, item[0]]
        })
        break
      case 2:
        item[1].forEach((innerItem) => {
          result.push({
            name: topLevelMenuName + ' - ' + item[0] + ' - ' + innerItem,
            menu: [topLevelMenuName, item[0], innerItem]
          })
        })
        break
      }
    })
  })

  console.log(yaml.safeDump({operations: result}))
} catch (e) {
  console.log(e)
  process.exit(1)
}
