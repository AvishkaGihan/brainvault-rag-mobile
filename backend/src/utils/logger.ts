/**
 * Utility Logger
 * Simple logging utility for consistent formatting
 */

const LOG_LEVELS = {
  DEBUG: "DEBUG",
  INFO: "INFO",
  WARN: "WARN",
  ERROR: "ERROR",
} as const;

type LogLevel = (typeof LOG_LEVELS)[keyof typeof LOG_LEVELS];

class Logger {
  private prefix = "[BrainVault]";

  private formatMessage(
    level: LogLevel,
    message: string,
    data?: unknown,
  ): string {
    const timestamp = new Date().toISOString();
    const baseMessage = `${this.prefix} [${timestamp}] [${level}] ${message}`;

    if (data) {
      return `${baseMessage} ${JSON.stringify(data)}`;
    }
    return baseMessage;
  }

  debug(message: string, data?: unknown): void {
    if (process.env.NODE_ENV === "development") {
      console.log(this.formatMessage(LOG_LEVELS.DEBUG, message, data));
    }
  }

  info(message: string, data?: unknown): void {
    console.log(this.formatMessage(LOG_LEVELS.INFO, message, data));
  }

  warn(message: string, data?: unknown): void {
    console.log(this.formatMessage(LOG_LEVELS.WARN, message, data));
  }

  error(message: string, data?: unknown): void {
    console.log(this.formatMessage(LOG_LEVELS.ERROR, message, data));
  }
}

export const logger = new Logger();
