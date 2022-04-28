'use strict'
const solpp = require('solpp');
const path = require('path');
const fs = require('fs');

require('json5/lib/register')

const OPTS = {
    defs: require(path.resolve(__dirname, './defs.json5'))
}

async function preprocess_code(INPUT_FILE, OUTPUT_FILE, preprocessing_depth, file_sep) {
    var input;
    try {
        input = fs.readFileSync(INPUT_FILE);
    } catch (err) {
        console.error(err);
    }

    var output = await solpp.processFile(INPUT_FILE, OPTS);
    for (var i = 0; i < preprocessing_depth; i++) {
        var output = await solpp.processCode(output, OPTS);
    }

    var in_begin_idx = input.indexOf(file_sep)
    var out_begin_idx = output.indexOf(file_sep)
    if (in_begin_idx == -1 || out_begin_idx == -1) {
        console.error("Separator not found in files!");
        return;
    }

    output = input.slice(0, in_begin_idx) + output.slice(out_begin_idx)

    try {
        fs.writeFileSync(OUTPUT_FILE, output);
    } catch (err) {
        console.error(err);
    }
}

if (require.main == module) {
    (async function () {
        const preprocessing_depth = 2;

        var INPUT_FILE = path.resolve(__dirname, './contracts/commitments/fri_verifier_unprocessed.sol.txt');
        var OUTPUT_FILE = path.resolve(__dirname, './contracts/commitments/fri_verifier.sol');
        await preprocess_code(INPUT_FILE, OUTPUT_FILE, preprocessing_depth, "library fri_verifier");
    })();
}
