asTable = require('as-table')
const fs = require("fs");
var file = 'time.log';

names = ["Non-native field element addition", "Non-native field element multiplication", "Non-native field element subtraction",
    "Non-native field element range check", "Unified addition", "Variable base scalar mul"]

var text = fs.readFileSync(file).toString().trim();
text = text.split("\n")

console.log(asTable.configure({delimiter: ' | '})([
    {Name: names[0], Time: text[0].split(" ")[1], Status: "Done", Verification_Gas: "-"},
    {Name: names[1], Time: text[1].split(" ")[1], Status: "Done", Verification_Gas: "-"},
    {Name: names[2], Time: text[2].split(" ")[1], Status: "Done", Verification_Gas: "-"},
    {Name: names[3], Time: text[3].split(" ")[1], Status: "Done", Verification_Gas: "-"},
    {Name: names[4], Time: text[4].split(" ")[1], Status: "Done", Verification_Gas: "-"},
    {Name: names[5], Time: text[5].split(" ")[1], Status: "Done", Verification_Gas: "-"}
    ])
)