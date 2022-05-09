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
        names.map(drawTableRow)
    )
}

function drawTableRow(name, index) {
    return {
        Name: name,
        Time: text[index].split(" ")[1],
        Status: 'Done',
        Verification_Gas: '-'
    }
}

console.log(drawTable())
