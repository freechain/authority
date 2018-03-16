const path = require("path");
const fs = require('fs');

function getPath(relativePath) {
	return path.resolve(__dirname, '..', relativePath);
}

const configPath = getPath("./config.json");
let configExists = fs.existsSync(configPath, fs.F_OK);
let config;
if (configExists) config = JSON.parse(fs.readFileSync(configPath, "utf8"));
config.inputSourcePath = getPath(config.inputSourcePath);
config.outputDir = getPath(config.outputDir);

//Input solidity file path
let args = process.argv.slice(2);
let inputSourcePath = args.length > 0 ? args[0] : config ? config.inputSourcePath : "";
//Input solidity file dir name
let inputFileDir = path.dirname(inputSourcePath);
//Input parent dir
let parentDir = inputFileDir;
//Output directory to store flat combined solidity file
let outDir = args.length > 1 ? args[1] : config ? config.outputDir : getPath("./out");
let flatContractPrefix = args.length > 2 ? args[2] : path.basename(inputSourcePath, ".sol");

let allSrcFiles = [];
let importedSrcFiles = {};


module.exports = {
	args: args,
	inputSourcePath: inputSourcePath,
	inputFileDir: inputFileDir,
	parentDir: parentDir,
	outDir: outDir,
	allSrcFiles: allSrcFiles,
	importedSrcFiles: importedSrcFiles,
	flatContractPrefix: flatContractPrefix
}