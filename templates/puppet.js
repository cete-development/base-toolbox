const puppeteer = require("puppeteer-extra");
const stealthplugin = require("puppeteer-extra-plugin-stealth");
const fs = require("fs");
const pup = require("./pup_functions.js");

// anti bot-detection plugin
puppeteer.use(stealthplugin());
const { executablePath } = require("puppeteer");
// const { constrainedMemory } = require('process');

const JSONFILE = JSON.parse(fs.readFileSync("signupData.json", "utf8")); // Read the JSON file
const timeoutDuration = 0.1; // In minutes
const base_url = "https://www.google.com";

async function run() {
  let browser;

  try {
    // Declare and launch browser
    browser = await puppeteer.launch({ userDataDir: "./tmp", executablePath: executablePath(),headless: false,});
    const page = await browser.newPage();
    await page.setDefaultTimeout(timeoutDuration * 60 * 1000);
    await page.goto(base_url, {waitUntil: "networkidle2",});

    // EXAMPLE for input field.
    try {
      // Wait for the input field to load. Custom timeout value of 3 seconds to overwrite the default timeout duration.
      await page.waitForSelector('input[name="email"]', { visible: true }, { timeout: 3000 });

      // Fill in the input field with name=email. use email value from jsonfile.
      await page.type('input[name="email"]', JSONFILE.email);

      // Wait 2 seconds.
      await page.evaluate(() => new Promise((resolve) => setTimeout(resolve, 2000)));

      // Click the submit button
      await page.waitForSelector('button[type="submit"]', { visible: true });
      await page.click('button[type="submit"]');

      console.log(pup.GetTimestamp() + " submit 1 ");
    } catch (error) {
      console.error("form 1 failed: ", error);
    }

    // EXAMPLE for dropdown menu entry.
    try {
      // Wait for the birthday inputs to load
      await page.waitForSelector('select[title="Year:"]', { visible: true });

      // The inputted JSON value has to correspond to one of the <options> value.
      // Select birthday day
      await page.select('select[title="Day:"]', JSONFILE.birthDay);
      // Select birthday month
      await page.select('select[title="Month:"]', JSONFILE.birthMonth);
      // Select birthday year
      await page.select('select[title="Year:"]', JSONFILE.birthYear);

      console.log(pup.GetTimestamp() + " bday filled ");
    } catch (error) {
      console.error("form 2 failed: ", error);
    }
    
    console.log(pup.GetTimestamp() + "Sign-up process completed");

  } catch (e) {
    console.error("Something Failed", e);
  } finally {
    console.log(pup.GetTimestamp() + "Program Ended");
    clearInterval(interval_1);
    await browser.close();
  }
}

// Print console log with timestamp every 30 minutes
var interval_1 = setInterval(function () {console.log(pup.GetTimestamp() + "...");}, 30 * 60 * 1000);

run();
