myBundle = require("./verifyPlaceholderUnifiedAddition.js")
Module = require("./auxProofGen.js")

Module['onRuntimeInitialized'] = function() {
    var t = Module.ccall('proof_gen', // name of C function
        'string', // return type
        null, // argument types
        null // arguments
    );
    t = t.slice(0, -1); // remove /n from the end
    // console.log(t)
    // document.writeln("Blob:");
    // document.writeln(t);
    // myBundle.verifyPlaceholderUnifiedAddition(t).then(res => document.writeln("Result verify: ", res))
    // myBundle.estimateGasPlaceholderUnifiedAddition(t).then(res => document.writeln("Gas: ", res));
    myBundle.verifyPlaceholderUnifiedAddition(t).then(res => console.log("Result verify: ", res.verify, ' Gas used:', res.gasUsed))
}