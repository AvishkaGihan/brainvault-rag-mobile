import { ChatGoogleGenerativeAI } from "@langchain/google-genai";
import dotenv from "dotenv";
dotenv.config();

export const createLLM = () => {
  return new ChatGoogleGenerativeAI({
    modelName: "gemini-pro",
    apiKey: process.env.GOOGLE_API_KEY,
    temperature: 0.3,
  });
};
