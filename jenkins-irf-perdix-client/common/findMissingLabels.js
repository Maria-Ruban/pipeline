const fs = require('fs');
const path = require('path');
const mysql = require('mysql');
var lzma = require("lzma");
const exp = /[\t\s'"]title[\t\s'"]?\:[\t\s]?("(.*?)"|'(.*?)')/g;

var connectionUrl = 'mysql://financialForms:financialForms@dev.kinara.perdix.co.in/financialForms';
var skipFilenames = false;
for (i = 2; i < process.argv.length; i++) {
    if (process.argv[i].startsWith("mysql://")) {
        connectionUrl = process.argv[i];
    } else if (process.argv[i] == "--skipFilenames") {
        skipFilenames = true;
    }
}

var allLabels = {};
var callback = (relative, items) => {
    items.forEach(item => {
        var absPath = relative+path.sep+item;
        var stat = fs.lstatSync(absPath);
        if (stat.isDirectory()) {
            var i = fs.readdirSync(absPath);
            callback(absPath, i);
        } else if (stat.isFile()) {
            var content = fs.readFileSync(absPath, {encoding: "utf8"});
            while (match = exp.exec(content)) {
                if (match[2] && match[2].trim()) {
                    allLabels[match[2].trim()] = absPath;
                }
            }
        }
    });
};
[
    'source/dev-www/process'
].forEach(i => callback(i, fs.readdirSync(i)));

var connection = mysql.createConnection(connectionUrl);
connection.connect();
try {
    connection.query("SELECT CONVERT(label_code USING utf8) label_code FROM translations", (e, results) => {
        if (e) throw e;
        results.forEach(i => delete allLabels[i.label_code.trim()]);
        var labelCodes = [];
        for (k in allLabels) {
            if (allLabels.hasOwnProperty(k)) {
                labelCodes.push({
                    label_code: k,
                    path: allLabels[k]
                });
            }
        }
        var missingLabelsFilename = connectionUrl.match(/@(.+)\//)[1]+" - "+new Date().toISOString();
        if (skipFilenames) {
            var missingLabels = "";
            missingLabels += labelCodes.map(i => i.label_code).join("\n");
        } else {
            var pageWise = labelCodes.reduce((map, i) => {map[i.path] = map[i.path] || []; map[i.path].push(i.label_code); return map}, {});
            var missingLabels = "";
            for (i in pageWise) {
                if (pageWise.hasOwnProperty(i)) {
                    missingLabels += i + "\n\t" + pageWise[i].join("\n\t") + "\n";
                }
            }
        }
        var missingLabelsBitty = 'https://itty.bitty.site/#/'+Buffer.from(lzma.compress("<h3>Missing Labels</h3><h4>"+missingLabelsFilename+"</h4><pre>"+missingLabels+"</pre>", 9)).toString('base64')
        // fs.writeFileSync("missingLabels", missingLabelsBitty);
        console.log(missingLabelsBitty);
        if (missingLabels) {
            process.exit(1);
        }
    });
} finally {
    connection.end();
}