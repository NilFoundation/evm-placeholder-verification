asTable = require('as-table')
const fs = require("fs");
var file = 'time.log';

names = ["Get Data", "Proof Generation Public", "Proof Generation Private", "Unified Addition"]

var text = fs.readFileSync(file).toString().trim();
text = text.split("\n")

console.log(asTable.configure({delimiter: ' | '})([
    {Name: names[0], Time: text[0].split(" ")[1], Status: "Done", Verification_Gas: "-"},
    {Name: names[1], Time: text[1].split(" ")[1], Status: "Done", Verification_Gas: "-"},
    {Name: names[2], Time: text[2].split(" ")[1], Status: "Done", Verification_Gas: "-"},
    {Name: names[3], Time: text[3].split(" ")[1], Status: text[3].split(" ")[2], Verification_Gas: text[3].split(" ")[3]},
    ])
)