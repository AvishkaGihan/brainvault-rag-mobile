import winston from "winston";
import { env } from "./env";

/**
 * Custom log format that combines timestamp, log level, and message.
 * In development, this includes colorization for better readability.
 */
const logFormat = winston.format.combine(
  winston.format.timestamp({ format: "YYYY-MM-DD HH:mm:ss" }),
  winston.format.errors({ stack: true }), // Print stack trace for errors
  winston.format.splat(),
  winston.format.json() // Default to JSON for structural integrity
);

/**
 * Winston logger configuration.
 * * Write all logs with importance level of `info` or less to `combined.log`
 * * Write all logs with importance level of `error` or less to `error.log`
 */
export const logger = winston.createLogger({
  level: env.NODE_ENV === "development" ? "debug" : "info",
  format: logFormat,
  defaultMeta: { service: "brainvault-api" },
  transports: [
    //
    // - Write all logs with importance level of `error` or less to `logs/error.log`
    //
    new winston.transports.File({ filename: "logs/error.log", level: "error" }),
    //
    // - Write all logs with importance level of `info` or less to `logs/combined.log`
    //
    new winston.transports.File({ filename: "logs/combined.log" }),
  ],
});

//
// If we're not in production then log to the `console` with the format:
// `${info.level}: ${info.message} JSON.stringify({ ...rest }) `
//
if (env.NODE_ENV !== "production") {
  logger.add(
    new winston.transports.Console({
      format: winston.format.combine(
        winston.format.colorize(),
        winston.format.printf(
          ({
            level,
            message,
            timestamp,
            stack,
            ...meta
          }: Record<string, unknown>) => {
            const metaString = Object.keys(meta).length
              ? JSON.stringify(meta)
              : "";
            const stackString = stack ? `\n${stack}` : "";
            return `${timestamp} ${level}: ${message} ${metaString}${stackString}`;
          }
        )
      ),
    })
  );
}
