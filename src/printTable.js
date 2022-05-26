const asTable = require('as-table')
const fs = require("fs");
const file = 'time.log';

const names = [
    'blueprint_hashes_plonk_decomposition_test', 'blueprint_non_native_plonk_non_native_range_test', 'blueprint_non_native_plonk_var_base_mul_per_bit_test',
    'blueprint_non_native_plonk_field_mul_test', 'blueprint_non_native_plonk_complete_addition_test', 'blueprint_non_native_plonk_field_sub_test'
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