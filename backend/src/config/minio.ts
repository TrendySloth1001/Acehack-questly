import * as Minio from "minio";
import { env } from "./env";

export const minioClient = new Minio.Client({
  endPoint: env.MINIO_ENDPOINT,
  port: env.MINIO_PORT,
  useSSL: env.MINIO_USE_SSL,
  accessKey: env.MINIO_ACCESS_KEY,
  secretKey: env.MINIO_SECRET_KEY,
});

/**
 * Ensure the default bucket exists on startup.
 */
export async function ensureBucket(): Promise<void> {
  const exists = await minioClient.bucketExists(env.MINIO_BUCKET);
  if (!exists) {
    await minioClient.makeBucket(env.MINIO_BUCKET, "us-east-1");
    console.log(`✅ MinIO bucket "${env.MINIO_BUCKET}" created`);

    // Set public-read policy so presigned URLs work
    const policy = {
      Version: "2012-10-17",
      Statement: [
        {
          Effect: "Allow",
          Principal: { AWS: ["*"] },
          Action: ["s3:GetObject"],
          Resource: [`arn:aws:s3:::${env.MINIO_BUCKET}/*`],
        },
      ],
    };
    await minioClient.setBucketPolicy(
      env.MINIO_BUCKET,
      JSON.stringify(policy)
    );
  }
}
