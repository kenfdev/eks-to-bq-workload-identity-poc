const { BigQuery } = require("@google-cloud/bigquery");
const path = require("path");

async function main() {
  const projectId = "eks-to-bq-poc";
  const datasetId = "customers";
  const tableId = "customers";

  const bigquery = new BigQuery({
    projectId,
    // keyFilename: path.join(__dirname, "eks-to-bq-poc-ee4056a6423a.json") ,
  });

  const query = `SELECT * FROM \`${projectId}.${datasetId}.${tableId}\` LIMIT 10`;

  const [job] = await bigquery.createQueryJob({ query });
  console.log(`Job ${job.id} started.`);

  const [rows] = await job.getQueryResults();

  console.log("Rows:");
  rows.forEach((row) => console.log(row));
}

main().catch(console.error);