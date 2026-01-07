/**
 * Tests to validate backend project initialization
 * TASK 1: Initialize Node.js project with TypeScript
 */

import { describe, it, expect } from "@jest/globals";
import * as fs from "fs";
import * as path from "path";

describe("Backend Project Initialization", () => {
  describe("Project Structure", () => {
    it("should have package.json in backend root", () => {
      const packageJsonPath = path.join(__dirname, "../../package.json");
      expect(fs.existsSync(packageJsonPath)).toBe(true);
    });

    it("should have tsconfig.json with strict mode enabled", () => {
      const tsconfigPath = path.join(__dirname, "../../tsconfig.json");
      expect(fs.existsSync(tsconfigPath)).toBe(true);

      const tsconfig = JSON.parse(fs.readFileSync(tsconfigPath, "utf-8"));
      expect(tsconfig.compilerOptions.strict).toBe(true);
      expect(tsconfig.compilerOptions.target).toBe("ES2020");
    });

    it("should have nodemon.json configured for hot-reload", () => {
      const nodemonPath = path.join(__dirname, "../../nodemon.json");
      expect(fs.existsSync(nodemonPath)).toBe(true);

      const nodemon = JSON.parse(fs.readFileSync(nodemonPath, "utf-8"));
      expect(nodemon.watch).toContain("src");
      expect(nodemon.ext).toContain("ts");
    });

    it("should have .env.example documenting environment variables", () => {
      const envExamplePath = path.join(__dirname, "../../.env.example");
      expect(fs.existsSync(envExamplePath)).toBe(true);

      const envContent = fs.readFileSync(envExamplePath, "utf-8");
      expect(envContent).toContain("NODE_ENV");
      expect(envContent).toContain("PORT");
      expect(envContent).toContain("FIREBASE_PROJECT_ID");
      expect(envContent).toContain("PINECONE_API_KEY");
    });

    it("should have .gitignore configured", () => {
      const gitignorePath = path.join(__dirname, "../../.gitignore");
      expect(fs.existsSync(gitignorePath)).toBe(true);

      const gitignoreContent = fs.readFileSync(gitignorePath, "utf-8");
      expect(gitignoreContent).toContain("node_modules/");
      expect(gitignoreContent).toContain(".env");
    });
  });

  describe("Required Directories", () => {
    const requiredDirs = [
      "src",
      "src/config",
      "src/routes",
      "src/controllers",
      "src/services",
      "src/middleware",
      "src/types",
      "src/utils",
      "tests",
      "tests/unit",
      "tests/integration",
      "tests/fixtures",
    ];

    requiredDirs.forEach((dir) => {
      it(`should have ${dir} directory created`, () => {
        const dirPath = path.join(__dirname, "../../", dir);
        expect(fs.existsSync(dirPath)).toBe(true);
        expect(fs.statSync(dirPath).isDirectory()).toBe(true);
      });
    });
  });

  describe("Key Files", () => {
    it("should have src/index.ts entry point", () => {
      const indexPath = path.join(__dirname, "../../src/index.ts");
      expect(fs.existsSync(indexPath)).toBe(true);
      expect(fs.statSync(indexPath).isFile()).toBe(true);
    });
  });

  describe("Dependencies", () => {
    it("should have required core dependencies in package.json", () => {
      const packageJsonPath = path.join(__dirname, "../../package.json");
      const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, "utf-8"));

      const requiredDeps = [
        "express",
        "dotenv",
        "cors",
        "express-rate-limit",
        "langchain",
        "@langchain/google-genai",
        "@pinecone-database/pinecone",
        "firebase-admin",
        "multer",
        "pdf-parse",
      ];

      requiredDeps.forEach((dep) => {
        expect(packageJson.dependencies).toHaveProperty(dep);
      });
    });

    it("should have required dev dependencies in package.json", () => {
      const packageJsonPath = path.join(__dirname, "../../package.json");
      const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, "utf-8"));

      const requiredDevDeps = [
        "@types/node",
        "@types/cors",
        "@types/multer",
        "ts-node",
        "nodemon",
        "typescript",
        "jest",
        "ts-jest",
      ];

      requiredDevDeps.forEach((dep) => {
        expect(packageJson.devDependencies).toHaveProperty(dep);
      });
    });

    it("should have npm scripts configured", () => {
      const packageJsonPath = path.join(__dirname, "../../package.json");
      const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, "utf-8"));

      expect(packageJson.scripts).toHaveProperty("dev");
      expect(packageJson.scripts).toHaveProperty("build");
      expect(packageJson.scripts).toHaveProperty("start");
      expect(packageJson.scripts).toHaveProperty("test");
    });
  });

  describe("Configuration Files", () => {
    it("should have src/config/env.ts for environment variables", () => {
      const envPath = path.join(__dirname, "../../src/config/env.ts");
      expect(fs.existsSync(envPath)).toBe(true);
    });

    it("should have src/config/firebase.ts placeholder", () => {
      const firebasePath = path.join(__dirname, "../../src/config/firebase.ts");
      expect(fs.existsSync(firebasePath)).toBe(true);
    });

    it("should have src/config/pinecone.ts placeholder", () => {
      const pineconePath = path.join(__dirname, "../../src/config/pinecone.ts");
      expect(fs.existsSync(pineconePath)).toBe(true);
    });

    it("should have src/config/llm.ts placeholder", () => {
      const llmPath = path.join(__dirname, "../../src/config/llm.ts");
      expect(fs.existsSync(llmPath)).toBe(true);
    });
  });

  describe("README Documentation", () => {
    it("should have README.md in backend root", () => {
      const readmePath = path.join(__dirname, "../../README.md");
      expect(fs.existsSync(readmePath)).toBe(true);

      const readmeContent = fs.readFileSync(readmePath, "utf-8");
      expect(readmeContent).toContain("Node.js");
      expect(readmeContent).toContain("npm install");
      expect(readmeContent).toContain("npm run dev");
    });
  });
});
