const asTable = require('as-table')
const fs = require("fs");
const file = 'time.log';

const names = [
"Non-native field element addition",
    "Non-native field element multiplication",
    "Non-native field element subtraction",
    "Non-native field element range check",
    "Non-native complete addition",
    "Non-native variable-base per-bit multiplication",
    "Non-native fixed-base multiplication"
]

const delimiter = ' | ';

var text = fs.readFileSync(file).toString().trim();
text = text.split("\n")

function drawTable () {
    return asTable.configure({delimiter})(
        names.reduce(drawTableRow, [])
    )
}

function drawTableRow(prev, current, index) {
    const rowText = text[index];

    if (!rowText) {
        return prev;
    }

    prev.push({
        Name: current,
        Time: rowText.split(" ")[1],
        Status: 'Done',
        Verification_Gas: '-'
    })

    return prev;
}

console.log(drawTable())