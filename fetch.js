#!/usr/bin/env node
const puppeteer = require("puppeteer");

const url_prefix = "https://www.laundryalert.com/cgi-bin/ucla6023/LMRoom?CallingPage=LMPage&Halls=";

async function main(opts = {quiet:false}, dorm=8) {
    const browser = await puppeteer.launch({
      headless: true,
      args: ["--no-sandbox", "--disable-setuid-sandbox"],
    });
    const page = await browser.newPage();

    await page.goto(url_prefix + dorm);

    let machines = await page.evaluate(() => {
        let machines = [];

        const row_count = document.querySelector(
                `#tablea > tbody > tr:nth-child(1) > td:nth-child(4) > form `+
                `> table:nth-child(4) > tbody`).children.length;

        // maximum 1000 machines
        for (let i = 2; i < row_count-1; i++) {
            let tr = document.querySelector(
                `#tablea > tbody > tr:nth-child(1) > td:nth-child(4) > form `+
                `> table:nth-child(4) > tbody > tr:nth-child(${i})`);

            let tds = tr.children;
            let index  = tds[2].children[0].children[0].children[0].innerHTML.trim();
            let type   = tds[3].children[0].children[0].innerHTML.trim();
            let status = tds[4].children[0].children[0].innerHTML.trim();
            let eta    = tds[5];

            // clean up status
            status = status.replace("<br>", "-").replace(/<(?:.|\n)*?>/gm, "");

            // clean up eta
            if (eta.innerHTML.trim().startsWith("<font"))
                eta = eta.children[0].innerHTML.trim();
            else
                eta = eta.innerHTML.trim();
            if (eta == "&nbsp;")
                eta = "";

            machines.push({index, type, status, eta});
        }

        return machines;
    });

    // account for weird dryer #2
    if (dorm === 8) // Hedrick Hall
        machines[1].type = machines[1].type.replace("Washer", "Dryer");

    if (!opts.quiet) {
        console.log("# " + (new Date()).toLocaleString());
        console.log("index,type,status,eta");
        for (let m of machines) {
            console.log(`${m.index},${m.type},${m.status},${m.eta}`);
        }
    }

    browser.close();
    return machines;
}

module.exports = main;

// program called directly with ./fetch.js
if (require.main === module)
    main();
