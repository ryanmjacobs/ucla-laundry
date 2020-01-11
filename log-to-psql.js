#!/usr/bin/env node

const laundry  = require("./fetch");
const { Pool } = require("pg");

const pool = new Pool();

async function push(machines) {
  const client = await pool.connect();

  try {
    await client.query("BEGIN");

    const res = machines.map(machine => {
      return client.query(
        "INSERT INTO ucla_laundry" +
        "  (dorm, index, type, status, eta)" +
        "  VALUES ($1, $2, $3, $4, $5) RETURNING *",
        ["Hedrick Hall", machine.index, machine.type, machine.status, machine.eta]
      );
    });

    console.log((await Promise.all(res)).map(result => result.rows[0]));
    await client.query("COMMIT");
  } catch (e) {
    await client.query("ROLLBACK");
    throw e;
  } finally {
    await client.release();
  }
}

laundry({quiet:true}).then(push);
