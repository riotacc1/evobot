import { Client, GatewayIntentBits } from "discord.js";
import { Bot } from "./structs/Bot";
import { startExpressServer } from "./expressServer"; // Import the Express server

export const bot = new Bot(
  new Client({
    intents: [
      GatewayIntentBits.Guilds,
      GatewayIntentBits.GuildVoiceStates,
      GatewayIntentBits.GuildMessages,
      GatewayIntentBits.GuildMessageReactions,
      GatewayIntentBits.MessageContent,
      GatewayIntentBits.DirectMessages
    ]
  })
);

startExpressServer(); // Start the Express server
