const path = require("node:path");
const distributor = process.argv[2];
const resource = process.argv[3];

let convert;
try {
  convert = require(`./converters/${distributor}.js`).default;
} catch (err) {
  console.error(err);
  console.error(`${process.argv[1]}: Unrecognized bookmark distributor`);
  process.exit(1);
}

let resourcePath, resourceJSON;
try {
  resourcePath= path.resolve(resource);
  resourceJSON = require(resourcePath);
} catch (err) {
  console.error(err);
  console.error(`${process.argv[1]}: Missing bookmarks input file`);
  process.exit(1);
}

if (!process.env.BOOKMARKSPATH) {
  throw new Error(`${process.argv[1]}: Missing bookmarks output file`)
}

const bookmarks = convert(resourceJSON);
const tags = require("./tags.js");

const { createWriteStream } = require("node:fs");

const bookmarksfile = createWriteStream(process.env.BOOKMARKSPATH, {
  flags: "a",
  encoding: "utf8",
});

bookmarksfile.on("close", (...args) => {
  console.log(`${process.argv[1]}: ${bookmarks.length} new bookmarks imported!`);
  process.exit(0);
});

writeData(0);

function writeData(i) {
  if (i === bookmarks.length) {
    bookmarksfile.end();
    return;
  }

  tags.domain2tag(bookmarks[i]);
  const csvLine = Buffer.from(
    `${bookmarks[i].decodedURL},${bookmarks[i].title},${bookmarks[i].tags}\n`,
    "utf8",
  );
  bookmarksfile.write(csvLine, (error) => {
    if (!error) return writeData(i + 1);
    console.error(error);
    process.exit(1);
  });
}
