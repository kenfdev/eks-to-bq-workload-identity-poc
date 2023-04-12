const { BigQuery } = require("@google-cloud/bigquery");

async function main() {
  const projectId = "eks-to-bq-poc";
  const datasetId = "customers";
  const tableId = "customers";

  const bigquery = new BigQuery({
    projectId,
  });

  const query = `SELECT * FROM \`${projectId}.${datasetId}.${tableId}\` LIMIT 10`;

  const [job] = await bigquery.createQueryJob({ query });
  console.log(`Job ${job.id} started.`);

  const [rows] = await job.getQueryResults();

  console.log("Rows:");
  rows.forEach((row) => console.log(row));
}

main().catch(console.error);