myBundle = require("./verifyPlaceholderUnifiedAddition.js")
Module = require("./aux-proof-gen.js")
const fs = require("fs");

const mnemonic = fs.readFileSync(".secret").toString().trim();

Module['onRuntimeInitialized'] = function() {
    var t = Module.ccall('generate_proof', // name of C function
        'string', // return type
        null, // argument types
        null // arguments
    );
    t = t.slice(0, -1); // remove /n from the end
    myBundle.verifyPlaceholderUnifiedAddition(t, mnemonic).then(res => console.log("Result verify: ", res.verify, ' Gas used:', res.gasUsed))
}