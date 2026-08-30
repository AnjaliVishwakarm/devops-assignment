const fs = require("fs");
const assert = require("assert");

const html = fs.readFileSync("index.html", "utf8");

assert(
  html.includes("<!DOCTYPE html>"),
  "DOCTYPE is missing"
);

assert(
  html.includes("Ember"),
  "Application name is missing"
);

assert(
  html.includes("Start"),
  "Start functionality is missing"
);

assert(
  html.includes("Reset"),
  "Reset functionality is missing"
);

console.log("All unit tests passed!");