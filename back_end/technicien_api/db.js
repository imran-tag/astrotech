// db.js
const { Pool } = require('pg');
const dotenv = require('dotenv');
dotenv.config();

const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT || 5432,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  max: 10, // maximum number of clients in the pool
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

// Helper function to convert MySQL-style query with ? placeholders to PostgreSQL $1, $2, etc.
pool.execute = async function(sql, params = []) {
  // Convert ? placeholders to $1, $2, $3, etc.
  let index = 1;
  const convertedSql = sql.replace(/\?/g, () => `$${index++}`);

  const result = await pool.query(convertedSql, params);

  // Convert PostgreSQL result format to match MySQL2 format
  return [result.rows, result.fields];
};

module.exports = pool;
