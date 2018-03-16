function fixSpaces(content) {
	return content.replace(/(\n|\r|\r\n){2,}/g, '\n\n');
}

module.exports = fixSpaces;