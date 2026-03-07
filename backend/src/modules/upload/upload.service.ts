import { Readable } from "stream";
import { v4 as uuidv4 } from "uuid";
import { minioClient } from "../../config/minio";
import { prisma } from "../../config/database";
import { env } from "../../config/env";
import { NotFoundError, BadRequestError } from "../../shared/errors";
import { ERROR_MESSAGES, UPLOAD } from "../../shared/constants";
import {
  parsePagination,
  paginationMeta,
} from "../../shared/utils/pagination";

export interface UploadFileParams {
  buffer: Buffer;
  originalName: string;
  mimeType: string;
  size: number;
  userId: string;
}

export class UploadService {
  /**
   * Upload file to MinIO & persist metadata.
   */
  async uploadFile(params: UploadFileParams) {
    const { buffer, originalName, mimeType, size, userId } = params;

    // Validate
    if (size > UPLOAD.MAX_FILE_SIZE) {
      throw new BadRequestError(ERROR_MESSAGES.FILE_TOO_LARGE);
    }
    if (!UPLOAD.ALLOWED_MIME_TYPES.includes(mimeType as any)) {
      throw new BadRequestError(ERROR_MESSAGES.INVALID_FILE_TYPE);
    }

    const ext = originalName.split(".").pop() || "bin";
    const objectKey = `${userId}/${uuidv4()}.${ext}`;

    // Upload to MinIO
    const stream = Readable.from(buffer);
    await minioClient.putObject(env.MINIO_BUCKET, objectKey, stream, size, {
      "Content-Type": mimeType,
    });

    const url = this.buildUrl(objectKey);

    // Persist in DB
    return prisma.upload.create({
      data: {
        fileName: originalName,
        mimeType,
        size,
        bucket: env.MINIO_BUCKET,
        objectKey,
        url,
        userId,
      },
    });
  }

  /**
   * Get presigned URL for private download (1 hour).
   */
  async getPresignedUrl(userId: string, uploadId: string): Promise<string> {
    const upload = await prisma.upload.findFirst({
      where: { id: uploadId, userId },
      select: { objectKey: true, bucket: true },
    });
    if (!upload) throw new NotFoundError(ERROR_MESSAGES.NOT_FOUND);

    return minioClient.presignedGetObject(upload.bucket, upload.objectKey, 3600);
  }

  /**
   * List user uploads with pagination.
   */
  async listUploads(userId: string, page?: string, limit?: string) {
    const { page: p, limit: l, skip } = parsePagination(page, limit);

    const [total, uploads] = await prisma.$transaction([
      prisma.upload.count({ where: { userId } }),
      prisma.upload.findMany({
        where: { userId },
        skip,
        take: l,
        orderBy: { createdAt: "desc" },
      }),
    ]);

    return { uploads, meta: paginationMeta(total, p, l) };
  }

  /**
   * Delete file from MinIO + DB.
   */
  async deleteFile(userId: string, uploadId: string) {
    const upload = await prisma.upload.findFirst({
      where: { id: uploadId, userId },
    });
    if (!upload) throw new NotFoundError(ERROR_MESSAGES.NOT_FOUND);

    await minioClient.removeObject(upload.bucket, upload.objectKey);
    await prisma.upload.delete({ where: { id: uploadId } });
  }

  // ── Private ──────────────────────────────────────────────

  private buildUrl(objectKey: string): string {
    // Serve via backend proxy so mobile devices can reach the file
    // Route: GET /files/:bucket/:objectKey
    const base = env.PUBLIC_URL || `http://localhost:${env.PORT || 3000}`;
    return `${base}/files/${env.MINIO_BUCKET}/${objectKey}`;
  }
}

export const uploadService = new UploadService();
