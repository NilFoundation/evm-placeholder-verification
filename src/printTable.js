const asTable = require('as-table')
const fs = require("fs");
const file = 'time.log';

const names = [
    "Endo Scalar",
    "Variable Base Scalar Mul",
    "Field Operations",
    "Multi Scalar Multiplication",
    "Unified Addition"
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
