const fs = require('fs');
const path = require('path');

// Function to create a directory recursively
function createDirectory(dirPath) {
  if (!fs.existsSync(dirPath)) {
    try {
      fs.mkdirSync(dirPath, { recursive: true });
      console.log(`Created directory: ${dirPath}`);
    } catch (err) {
      console.error('Error creating directory:', err);
    }
  } else {
    console.log(`Directory already exists: ${dirPath}`);
  }
}

// Function to save JSON data to a file
function saveJSON(data, filePath) {
  fs.writeFile(filePath, JSON.stringify(data, null, 2), (err) => {
    if (err) {
      console.error('Error saving JSON file:', err);
    } else {
      console.log(`JSON file saved successfully: ${filePath}`);
    }
  });
}

// Read Json file.
function readJSON(filePath) {
  try {
    const fileContent = fs.readFileSync(filePath, 'utf-8');
    const jsonData = JSON.parse(fileContent);
    return jsonData;
  } catch (err) {
    console.error(GetTimestamp() + 'Error reading JSON file: File might not exist, Returning empty array');
    return [];
  }
}

function SaveData(filename, subfolderName, data) {
  //const filename = 'data.json';
  //const subfolderName = 'mySubfolder';

  // Create subfolder path
  const subfolderPath = path.join(__dirname, subfolderName);

  // Create the subfolder if it doesn't exist
  createDirectory(subfolderPath);

  const filePath = path.join(subfolderPath, filename);
  saveJSON(data, filePath);
}

function GetDate() {
  let currentDate = new Date();
  let cDay = currentDate.getDate();
  let cMonth = currentDate.getMonth() + 1;
  let cYear = currentDate.getFullYear();
  return cDay + '-' + cMonth + '-' + cYear
}

function GetTimestamp() {
  const pad = (n, s = 2) => (`${new Array(s).fill(0)}${n}`).slice(-s);
  const d = new Date();

  return `[${pad(d.getDate())}-${pad(d.getMonth() + 1)}-${pad(d.getFullYear(), 4)} ${pad(d.getHours())}:${pad(d.getMinutes())}:${pad(d.getSeconds())}] `;
}

// Pause for 'time' duration in seconds
function Delay(time) {
  return new Promise(function (resolve) {
    setTimeout(resolve, time * 1000)
  });
}

module.exports = {
  createDirectory,
  saveJSON,
  readJSON,
  SaveData,
  GetDate,
  Delay,
  GetTimestamp
};