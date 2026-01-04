import fs from "fs";
import multer, { FileFilterCallback } from "multer";
import path from "path";
import crypto from "crypto";
import { Request } from "express";
import { AppError } from "../errors/app-error";

const MAX_FILE_SIZE = 5 * 1024 * 1024; // 5MB
const UPLOAD_DIR = "./uploads";

// Ensure upload directory exists
if (!fs.existsSync(UPLOAD_DIR)) {
  fs.mkdirSync(UPLOAD_DIR, { recursive: true });
}

/**
 * Configure Multer disk storage
 * - Destination: ./uploads
 * - Filename: timestamp_random_sanitizedName
 */
const storage = multer.diskStorage({
  destination: (
    req: Request,
    file: Express.Multer.File,
    cb: (error: Error | null, destination: string) => void
  ) => {
    cb(null, UPLOAD_DIR);
  },
  filename: (
    req: Request,
    file: Express.Multer.File,
    cb: (error: Error | null, filename: string) => void
  ) => {
    // Sanitize filename: remove non-alphanumeric chars (except . and -) and spaces
    const sanitizedOriginalName = file.originalname.replace(
      /[^a-zA-Z0-9.-]/g,
      "_"
    );
    const randomString = crypto.randomBytes(8).toString("hex");
    const filename = `${Date.now()}_${randomString}_${sanitizedOriginalName}`;
    cb(null, filename);
  },
});

/**
 * File filter to ensure only PDFs are uploaded
 */
const fileFilter = (
  req: Request,
  file: Express.Multer.File,
  cb: FileFilterCallback
) => {
  if (file.mimetype === "application/pdf") {
    cb(null, true);
  } else {
    // Reject file
    cb(new AppError(415, "INVALID_FILE_TYPE", "Only PDF files are allowed"));
  }
};

/**
 * Export configured multer middleware
 * Usage: upload.single('file')
 */
export const upload = multer({
  storage: storage,
  fileFilter: fileFilter,
  limits: {
    fileSize: MAX_FILE_SIZE,
  },
});
