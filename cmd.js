const fs = require('fs');

const repos = JSON.parse(fs.readFileSync('/repos'));
fs.writeFileSync('/repoNames', JSON.stringify(repos.map(repo => repo.name)));