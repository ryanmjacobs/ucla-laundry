#!/usr/bin/env node

const laundry    = require("./fetch");
const dorm_names = require("./dorm_names");

const { Pool } = require("pg");

const pool = new Pool();

async function push(machines, dorm_name, dorm_id) {
  const client = await pool.connect();

  try {
    await client.query("BEGIN");

    const res = machines.map(machine => {
      return client.query(
        "INSERT INTO ucla_laundry" +
        "  (dorm_name, dorm_id, index, type, status, eta)" +
        "  VALUES ($1, $2, $3, $4, $5) RETURNING *",
        [dorm_name, dorm_id, machine.index, machine.type, machine.status, machine.eta]
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

dorm_names.map(async (name, index) => {
  const machines = await laundry({quiet:true}, index);
  await push(machines, name, index);
});
