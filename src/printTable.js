const asTable = require('as-table')
const fs = require("fs");
const file = 'time.log';

const names = [
    "Get Data",
    "Proof Generation Public",
    "Proof Generation Private",
    "Unified Addition",
    "Endo Scalar Mul",
    "Scalar Mul",
    "Unified Addition"
]

const delimiter = ' | ';

var text = fs.readFileSync(file).toString().trim();
text = text.split("\n")

function drawTable () {
    return asTable.configure({delimiter: ' | '})(
        names.forEach(drawTableRow)
    )
}

function drawTableRow(name, index) {
    return {
        Name: name,
        Time: text[index].split(" ")[1],
        Status: index === 3 ? text[3].split(" ")[2] : 'Done',
        Verification_Gas: index === 3 ? text[3].split(" ")[3] : '-'
    }
}

console.log(drawTable())
